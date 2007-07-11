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
#    $Id: LinStruct.pir,v 1.1 2007/07/11 19:55:18 riouxp Exp $
#
#    $Log: LinStruct.pir,v $
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

- EndFieldsTable

- Methods

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
