#
# Implements SearchEngine for HMMER2
#
#    $Id: HMMER2SearchEngine.pir,v 1.8 2008/08/20 19:43:22 riouxp Exp $
#
#    $Log: HMMER2SearchEngine.pir,v $
#    Revision 1.8  2008/08/20 19:43:22  riouxp
#    Added CVS tracking variables.
#
#    Revision 1.7  2007/08/23 17:50:33  riouxp
#    Fixed bug when searcging with a MINUS strand HMM.
#
#    Revision 1.6  2007/07/13 21:44:50  riouxp
#    Improved time reporting.
#
#    Revision 1.5  2007/07/13 21:14:00  riouxp
#    Added timing info, for better logging.
#
#    Revision 1.4  2007/07/12 23:01:18  riouxp
#    Fixed bug with HMMbuild options.
#
#    Revision 1.3  2007/07/12 20:22:46  riouxp
#    Added new output parser that extract the alignment sequences.
#    Added options to hmmbuild to make sure all columns supplied
#    are considered significant (--fast --gapmax 1).
#
#    Revision 1.2  2007/07/11 22:08:27  riouxp
#    Fixed bug with empty internal elements.
#
#    Revision 1.1  2007/07/11 19:55:17  riouxp
#    New project. Initial check-in.
#
#    Added Files:
#        HMMweasel
#        HMMER2SearchEngine.pir LinStruct.pir PotentialResult.pir
#        RawDiskSeqs.pir RawSeq.pir ResultElement.pir SearchEngine.pir
#        SimpleHit.pir SimpleHitList.pir StructElem.pir
#

- PerlClass	PirObject::SearchEngine::HMMER2SearchEngine
- InheritsFrom	SearchEngine
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------

# These are in the superclass PirObject::SearchEngine
#rawdiskseqs             single          <RawDiskSeqs>   Must be tied to a file.
#tmpworkdir              single          string          Optional
#debug                   single          int4
tmpfiles                array           string
preparetimes            hash            int4

- EndFieldsTable

- Methods

use PirObject qw( SimpleHitList );

our $RCS_VERSION='$Id: HMMER2SearchEngine.pir,v 1.8 2008/08/20 19:43:22 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

# Returns an internal opaque token to be used by SearchSequences().
sub PrepareElementSearch {
    my $self           = shift;
    my $fastamultalign = shift; # The actual multiple alignment in text format, as a single string
    my $id             = shift; # Optional ID for this alignment.
    my $forstrand      = shift || ""; # Optional "+" or "-"; default is both

    my $tmpdir = $self->get_tmpworkdir() || "/tmp";
    $self->set_tmpworkdir($tmpdir);

    $id = int(rand(1000000)) if ! defined $id;
    die "ID must be an alphanum sequence.\n" unless $id =~ m#^\w[\w\.\-\+]*$#;

    my $token = "";
    my $HMMbuildOpts = "--fast --gapmax 1";

    my $starttime = time;

    # Build model for PLUS strand
    if ($forstrand ne "-") { # we do the test this way so we can build both + and - models
        my $fa_file = "$tmpdir/P-$id.fa";
        my $outfh = new IO::File ">$fa_file"
           or die "Cannot write to file '$fa_file': $!\n";
        print $outfh $fastamultalign;
        $outfh->close();

        # Build HMM with HMMER2
        my $HMMfile = "P-$id.hmm";
        print STDERR "Debug: building $HMMfile...\n" if $self->get_debug();
        system("cd $tmpdir || exit;hmmbuild $HMMbuildOpts $HMMfile $fa_file >out.$id.hbui 2>&1");
        # Calibrate HMM
        system("cd $tmpdir || exit;hmmcalibrate $HMMfile                    >out.$id.hcal 2>&1");

        my $tmpfiles = $self->get_tmpfiles();
        push(@$tmpfiles, $fa_file, $HMMfile, "out.$id.hbui", "out.$id.hcal");

        $token .= "\0" if $token ne "";
        $token .= $HMMfile;
    }

    # Build model for MINUS strand
    if ($forstrand ne "+") { # we do the test this way so we can build both + and - models
        my $fa_file = "$tmpdir/M-$id.fa";
        my $outfh = new IO::File ">$fa_file"
           or die "Cannot write to file '$fa_file': $!\n";
        print $outfh &_RevCompFastaFile($fastamultalign);
        $outfh->close();

        # Build HMM with HMMER2
        my $HMMfile = "M-$id.hmm";
        print STDERR "Debug: building $HMMfile...\n" if $self->get_debug();
        system("cd $tmpdir || exit;hmmbuild $HMMbuildOpts $HMMfile $fa_file >out.$id.hbui 2>&1");
        # Calibrate HMM
        system("cd $tmpdir || exit;hmmcalibrate $HMMfile                    >out.$id.hcal 2>&1");

        my $tmpfiles = $self->get_tmpfiles();
        push(@$tmpfiles, $fa_file, $HMMfile, "out.$id.hbui", "out.$id.hcal");

        $token .= "\0" if $token ne "";
        $token .= $HMMfile;
    }

    my $prephash = $self->get_preparetimes() || {};
    $prephash->{$token} = time-$starttime;
    $self->set_preparetimes($prephash);

    $token;
}

sub SearchSequences {
    my $self           = shift;
    my $token          = shift || die "Internal error: need token\n"; # as returned by PrepareElementSearch

    my $RawDiskSeqs    = $self->get_rawdiskseqs() || die "No rawdiskseqs configured?!?\n";
    my $searchFile     = $RawDiskSeqs->get_tiedfilename() || die "Need a tied filename ?!?\n";
    my $tmpdir         = $self->get_tmpworkdir()  || die "No tmp dir configured?!?\n";

    my $finalhitlist = [];
    my @HMMfiles = split(/\0/,$token);
    my $starttime=time;
    foreach my $HMMfile (@HMMfiles) {

        print STDERR "Debug: Searching with $HMMfile...\n" if $self->get_debug();

        # HMM search
        my $outfh = new IO::File "hmmsearch $tmpdir/$HMMfile $searchFile 2>/dev/null |"
            or die "Could not spawn hmmsearch command: $!\n";
        my @out = <$outfh>;
        $outfh->close();

        if ($self->get_debug()) {
            my $copyFh = new IO::File ">$tmpdir/out.$HMMfile.hsea";
            print $copyFh @out;
            $copyFh->close();
        }

        my $simplehitlist = &_ParseHMMSearchResult(\@out); # A PirObject::SimpleHitList
        my $hitlist = $simplehitlist->get_hitlist() || [];
        if ($HMMfile =~ m#^M-#) { # we need to transform the coordinates
            foreach my $hit (@$hitlist) {
                # NO NEED TO ADJUST COORDINATES
                #my $targetId = $hit->get_targetId();
                #my $hitStart = $hit->get_hitStart();
                #my $hitStop  = $hit->get_hitStop();
                #my $genomeObj = $RawDiskSeqs->GetRawSeqById($targetId);
                #my $genomeLen = $genomeObj->get_seqlength();
                $hit->set_hitStrand("-");
                my $seq = $hit->get_hitAlign();  # This need to be in the real forward dir
                $seq = reverse($seq);
                $seq =~ tr/acgtACGT/tgcaTGCA/;
                $hit->set_hitAlign($seq);
            }
        }
        push(@$finalhitlist, @$hitlist);
    }

    my $searchtime  = time-$starttime;
    my $preparetime = $self->get_preparetimes()->{$token};

    my $finalhitObj = new PirObject::SimpleHitList(
        preparetime => $preparetime,
        searchtime  => $searchtime,
        timetaken   => $preparetime+$searchtime,
        hitlist     => $finalhitlist,
    );

    $finalhitObj;
}


#SR0x00ba: domain 1 of 1, from 9766 to 9824: score -32.4, E = 7.3
#                   *->g.acgAAagcatggggAgcaAacagGATTaGatACCctggTAgtcca
#                      +  c AA+g++t   +A  aAa  g A T Gat C  t  TAg   a
#    SR0x00ba  9766    AaTCAAAGGTTT---TATGAAATCGAAATCGATTCTTTTTTAG---A 9806
#
#                   tgccgtaAAcgaTgaatg<-*
#                   t+ c   A  gaTg atg
#    SR0x00ba  9807 TATCTGGATAGATGGATG    9824
#
#SR0x00bb: domain 1 of 1, from 9766 to 9824: score -32.4, E = 7.3

sub _ParseHMMSearchResult { # Not a complete importer; not a method
    my $txt  = shift;  # text array ref

    my $hitlist = [];

    while (@$txt) {

        # Discard everything until "SR0x00ba: domain 1 of 1, from 9766 to"...
        shift(@$txt)
            while @$txt &&
            $txt->[0] !~ m#^\s*(\S+)\s*:\s*domain\s*\d+\s*of\s*\d+,\s*from\s*(\d+)\s*to\s*(\d+).*score\s*(\S+),\s*E\s*=\s*(\S+)#;
        last unless @$txt;
        my ($targetID,$from,$to,$score,$evalue) = ($1,$2,$3,$4,$5);
        shift(@$txt);

        # Extract alignment paragraph
        my @paragraph=();
        push(@paragraph,shift(@$txt))
            while @$txt && 
            $txt->[0] !~ m#domain\s*\d+\s*of\s*\d+|^Histogram|^% Statistical|^Total sequences#;

        # Extract aligned sequence from paragraph
        my $align = "";
        foreach my $paraline (@paragraph) {
           next unless $paraline =~ m#\d+\s*$# &&   # ends with a number
                       index($paraline,$targetID) >= 0;
           my ($subseq) = ($paraline =~ m#([^\s\d]+)\s*\d+\s*$#);
           $align .= $subseq;
        }

        die "No align?!?\nPARA=\n" . join("",@paragraph) . "REST=\n" . join("",@$txt) . "---\n"
            if $align eq "";

        $from--; $to--;  # converted to ZERO base

        my $obj = new PirObject::SimpleHit(
            targetId  => $targetID,
            hitStart  => $from,
            hitStop   => $to,
            hitStrand => "+",  # HMMSearch for HMMER2 is + strand only
            hitAlign  => $align,
            hitScore  => $score,
            hitEvalue => $evalue,
        );
        push(@$hitlist,$obj);
    }

    my $result = new PirObject::SimpleHitList (
        hitlist => $hitlist,
    );
    $result;
}

sub _RevCompFastaFile { # not a method
    my $txt = shift; # an entire multiple alignment in fasta format in a single string
    my @txt = split(/\n/,$txt);
    my $res = "";
    my @seq = ();
    while (@txt) {
        my $line = shift(@txt);
        next if $line =~ m#^\s*$|^\s*;#;
        $line =~ s/\s*$//;
        if ($line =~ m#^>#) {
            @seq = reverse(@seq);
            $_ = reverse($_) foreach @seq;
            tr/acgtACGT/TGCATGCA/ foreach @seq;
            $res .= join("\n",@seq) . "\n" if @seq;
            @seq=();
            $res .= "$line\n";
            next;
        }
        push(@seq,$line);
    }
    @seq = reverse(@seq);
    $_ = reverse($_) foreach @seq;
    tr/acgtACGT/TGCATGCA/ foreach @seq;
    $res .= join("\n",@seq) . "\n" if @seq;
    $res;
}

sub DESTROY {
    my $self = shift;
    return if $self->get_debug();

    my $tmpfiles = $self->get_tmpfiles();
    unlink @$tmpfiles;
}
