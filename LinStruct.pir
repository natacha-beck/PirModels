#
# Linear structure for molecular seq e.g
#
# 0000000000000000000000000
# 0000001111122222111113333
#
# meaning:
#
# ......(((((.....)))))....
#
# all properly parsed and packaged in neat objects.
#
#    $Id: LinStruct.pir,v 1.10 2008/08/20 19:43:22 riouxp Exp $
#
#    $Log: LinStruct.pir,v $
#    Revision 1.10  2008/08/20 19:43:22  riouxp
#    Added CVS tracking variables.
#
#    Revision 1.9  2008/08/01 20:58:08  riouxp
#    Improved detection of file vs filehandle.
#
#    Revision 1.8  2008/08/01 18:55:23  riouxp
#    Added ability to load a multalign from a filehandle
#    instead of just a filename. This allows you to bypass the
#    need for the "umac" external executable, if necessary.
#
#    Revision 1.7  2008/03/04 18:05:30  riouxp
#    Fixed syntax bug.
#
#    Revision 1.6  2008/03/04 18:02:35  riouxp
#    Adjusted multalign parser to ignore non-significant blank spaces.
#
#    Revision 1.5  2008/02/27 19:04:32  riouxp
#    Fixed the previous fix.
#
#    Revision 1.4  2008/02/27 18:46:03  riouxp
#    Handle situation when importing a struct+multalign file where
#    there are no multalign at all.
#
#    Revision 1.3  2007/07/18 21:24:14  riouxp
#    Added support for reading from a multiple alignment (and storing
#    the mutliple alignment itself).
#
#    Revision 1.2  2007/07/16 00:13:37  riouxp
#    HMMweasel: added -L option. HMMweasel and LinStruct: added support
#    for structure entries in a single line, such as "---AAAbbb---CCAAA---".
#
#    Revision 1.1  2007/07/11 19:55:18  riouxp
#    New project. Initial check-in.
#
#    Added Files:
#        HMMweasel
#        HMMER2SearchEngine.pir LinStruct.pir PotentialResult.pir
#        RawDiskSeqs.pir RawSeq.pir ResultElement.pir SearchEngine.pir
#        SimpleHit.pir SimpleHitList.pir StructElem.pir
#

- PerlClass	PirObject::LinStruct
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
structlength            single          int4            Total length
numloops                single          int4            Number of single stranded elements
numhelix                single          int4            Number of double stranded elements
idsByPos                hash            string          pos -> elem_id
elemsByIds              hash            <StructElem>    elem_id -> elem_obj
multalign               single          <MultAlign>     A multiple alignement to go with the struct

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: LinStruct.pir,v 1.10 2008/08/20 19:43:22 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub ImportFromTwoStrings {
    my $self    = shift;
    my $string1 = shift || "";   # e.g 0000000000000000000000000
    my $string2 = shift || "";   # e.g 0000001111122222111113333

    my $class = ref($self) || $self;

    $self = new $class() if $self eq $class; # make a new plain object

    my $len = length($string1);

    die "String1 and/or string2 not proper.\n"
         unless $len > 0 && $len == length($string2) &&
                $string1 =~ m#^\w+$# && $string2 =~ m#^\w+$#;

    my $elemsByIds = {};
    my $idsByPos   = {};
    my $numhelix   = 0;

    # Scan the two strings, character by character.
    for (my $i=0;$i<$len;$i++) {
        my $c1 = substr($string1,$i,1);
        my $c2 = substr($string2,$i,1);
        my $id = "$c1$c2";

        # New element never seen before?
        if (!exists($elemsByIds->{$id})) {
            my $elem = new PirObject::StructElem(
                elemId       => $id,
                elemType     => "LOOP",   # for the moment; might change.
                startposL    => $i,
                elemLength   => 1,   # for the moment, it's one
                startposR    => undef,
            );
            $elemsByIds->{$id}=$elem;
            $idsByPos->{$i}=$id;
            next;
        }

        # So we've seen this ID before.
        my $elem = $elemsByIds->{$id};
        my $type = $elem->get_elemType();
        my $pos  = $type eq "LOOP" ? $elem->get_startposL() : $elem->get_startposR();
        my $len  = $elem->get_elemLength();
        $pos += $len-1;

        # Continuation of a left or right element?
        if ($pos == $i-1) {
            $len++;
            $elem->set_elemLength($len);
            $idsByPos->{$i}=$id;
            next;
        }

        die "Error: structure contains more than 2 elements labeled \"$id\"\n"
            unless $type eq "LOOP";

        # Initialize right element.
        $elem->set_elemType("HELIX");
        $elem->set_startposR($i);
        $elem->set_elemLength(1); # resets for right side; TODO check both sides are same length?
        $idsByPos->{$i}=$id;
        $numhelix++;
    }

    # Create the object.
    my $numelems = scalar(keys %$elemsByIds);
    $self->SetMultipleFields(
        idsByPos     => $idsByPos,
        numloops     => $numelems-$numhelix,
        numhelix     => $numhelix,
        elemsByIds   => $elemsByIds,
        structlength => $len,
    );

    $self; # always an object, even if method is called as a class method.
}

sub ImportFromOneString {
    my $self   = shift;
    my $string = shift || "";   # e.g -----aaaaa----bbbbb---aaaaa----ccc---- ; dots and dashes are the SAME!

    die "Error: when building a structure from a pseudo-sequence, we support\n",
        "only the letters a-z, A-Z, the '-' and the '.'.\n"
        unless $string =~ m#^[a-zA-Z\-\.]+$#;

    $string =~ tr/./-/; # Dots and dashes are the same!

    my $string1 = $string;
    my $string2 = $string;

    # First, transform regions of '----' into 00, 01, 02 etc
    my $cnt  = "00";
    my $last = -9; # way outside range... -1 or 0 would cause a bug
    for (my $i=0;$i<length($string);$i++) {
        my $c = substr($string2,$i,1);
        if ($c ne "-") {
            substr($string1,$i,1) = "_"; # arbitrary char; will be removed later in all element IDs
            next;
        }
        $cnt++ if $i != $last+1;  # magical increment... 00, 01, 02, 03 etc etc
        $last = $i;
        substr($string1,$i,1) = substr($cnt,0,1);
        substr($string2,$i,1) = substr($cnt,1,1);
    }

    my $obj = $self->ImportFromTwoStrings($string1,$string2);

    # Now we adjust all the element IDs so that "#a", "#B" etc become simply "a", "B" etc.
    my $idsByPos   = $obj->get_idsByPos();
    foreach my $pos (keys %$idsByPos) {
        my $id = $idsByPos->{$pos};
        next unless $id =~ s/^_//;
        $idsByPos->{$pos}=$id;
    }

    my $elemsByIds = $obj->get_elemsByIds();
    foreach my $id (keys %$elemsByIds) {
        next unless $id =~ m/^_/;
        my $elem = delete $elemsByIds->{$id}; # remove from hash
        $id =~ s/^_//;
        $elem->set_elemId($id);
        $elemsByIds->{$id}=$elem; # reinsert in hash
    }

    $obj;
}

sub ImportFromMultipleAlignment { # FASTA reader, uses 'umac' as data converter.
    my $self = shift;
    my $file = shift; # filename or filehandle in class IO::File

    my $class = ref($self) || $self;
    $self = new $class() if $self eq $class; # make a new plain object

    my $fh = undef;
    if (ref($file) && $file->isa("IO::File")) {
        $fh = $file;
    } else {
        $fh = new IO::File "umac -K -i '$file' -o - -f FASTA|"
            or die "Cannot process multiple alignment file '$file' through umac?\n";
    }
    my @text = ( <$fh> ); # slurp;
    $fh->close();
    chomp @text;

    die "No content found in multiple alignment file '$file' ?!?\n" unless @text;

    # Extract the structure entry; we expect it to be the first one at the top.
    # Two different formats are supported: ERPIN (with twice the length of the sequence data)
    # and HMMmask (just a series of dashes and letters, e.g. ---AAA---bbb--CCCAAAdddd---"
    shift (@text) while @text && $text[0] =~ m#^\s*$#;
    die "Error: the multiple alignment file '$file' does not seem to start with a Structure or HMMmask entry.\n"
         unless @text && $text[0] =~ m#^>(Structure|HMMmask)#i;
    shift(@text);

    # Note: we cannot trust the number of lines returned
    # as the structure will have been reformated by umac...
    # TODO in umac: support -S with FASTA output?
    my $struct = "";
    $struct .= shift(@text) while @text && $text[0] !~ m#^>#;
    $struct =~ s/\s+//g;
    # We will parse the string $struct later, once we know the length of the
    # aligned sequences...

    my $seqlist = [];
    my $seqobj  = undef;
    my $seq     = "";

    for (my $i = 0; $i < @text; $i++) {
        my $line = $text[$i];
        if ($line =~ m#^>\s*(\S+)(\s+.*\S)?\s*$#) {
            my ($newid,$rest) = ($1,$2);
            $rest = "" if !defined($rest);
            if ($seqobj) {
                $seq =~ tr/a-zA-Z\-//cd; # MUST KEEP DASHES!
                $seqobj->set_sequence($seq);
            }
            $seq="";
            $seqobj = new PirObject::AlignedSeq(
                seqId        => $newid,
                seqFastaRest => $rest,
                sequence     => "",
            );
            push(@$seqlist,$seqobj);
            next;
        }
        $seq .= $line;
    }

    if ($seqobj) { # handle last seq in file
         $seq =~ tr/a-zA-Z\-//cd; # MUST KEEP DASHES!
         $seqobj->set_sequence($seq);
    }

    my $ma = new PirObject::MultAlign(
        alignId     => $file,  # not used really
        alignedSeqs => $seqlist,
    );

    # OK, let's go back to our single $struct line, and let's parse it.
    my $alilen = $ma->AlignmentLength();

    if ($alilen == 0) { # special case where there is no sequence data
        if ($struct =~ m#^\d+$# && (length($struct) & 1) == 0) { # GUESS that it's ERPIN format
            my $struct1 = substr($struct,0,length($struct)/2);
            my $struct2 = substr($struct,length($struct)/2);
            $self->ImportFromTwoStrings($struct1,$struct2);
        } else { # another guess, must be HMMmask
            $self->ImportFromOneString($struct);
        }
    }

    # Normal cases
    if (2*$alilen == length($struct)) { # Twice the length? Must be ERPIN format
        die "Error: structure entry is invalid in file '$file'.\n"
             unless $struct =~ m#^\d+$#; # digits only
        die "Error: structure entry contains odd number of digits.\n"
             unless (length($struct) & 1) == 0;
        my $struct1 = substr($struct,0,length($struct)/2);
        my $struct2 = substr($struct,length($struct)/2);
        $self->ImportFromTwoStrings($struct1,$struct2);
    } elsif ($alilen == length($struct)) { # Same length? Must by HMMmask
        $self->ImportFromOneString($struct);
    } elsif ($alilen != 0) {
        die "Error: the structure entry in your alignment file has length ".length($struct)." while\n" .
            "the sequences in the alignment have length $alilen.\n";
    }

    $self->set_multalign($ma);
    $self;
}

