#
# Implements SearchEngine for HMMER2
#
#    $Id: HMMER2SearchEngine.pir,v 1.2 2007/07/11 22:08:27 riouxp Exp $
#
#    $Log: HMMER2SearchEngine.pir,v $
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

- EndFieldsTable

- Methods

use PirObject qw( SimpleHitList );

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
        system("cd $tmpdir || exit;hmmbuild -g  $HMMfile $fa_file >out.$id.hbui 2>&1");
        # Calibrate HMM
        system("cd $tmpdir || exit;hmmcalibrate $HMMfile          >out.$id.hcal 2>&1");

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
        system("cd $tmpdir || exit;hmmbuild -f  $HMMfile $fa_file >out.$id.hbui 2>&1");
        # Calibrate HMM
        system("cd $tmpdir || exit;hmmcalibrate $HMMfile          >out.$id.hcal 2>&1");

        my $tmpfiles = $self->get_tmpfiles();
        push(@$tmpfiles, $fa_file, $HMMfile, "out.$id.hbui", "out.$id.hcal");

        $token .= "\0" if $token ne "";
        $token .= $HMMfile;
    }

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
            }
        }
        push(@$finalhitlist, @$hitlist);
    }

    my $finalhitObj = new PirObject::SimpleHitList(
        hitlist => $finalhitlist,
    );

    $finalhitObj;
}

sub _ParseHMMSearchResult { # Not a complete importer; not a method
    my $txt  = shift;  # text array ref

    my $hitlist = [];

    shift (@$txt) while @$txt && $txt->[0] !~ m#^Sequence Domain  seq-f seq-t#;
    shift (@$txt); shift(@$txt); # header line, dash line
    
    while (@$txt && $txt->[0] !~ m#^\s*$#) {
        my $line = shift(@$txt);
        $line =~ s/\s*$//;
        my @comps = split(/\s+/,$line);
        my ($targetID,$domain,$from,$to) = @comps; # first 4 components
        $from--; $to--;  # converted to ZERO base
        my ($score,$evalue) = ($comps[-2],$comps[-1]); # last 2 components
        my $obj = new PirObject::SimpleHit(
            targetId  => $targetID,
            hitStart  => $from,
            hitStop   => $to,
            hitStrand => "+",  # HMMSearch is + strand only
            #hitSeq    => "",  # not filled in yet
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
