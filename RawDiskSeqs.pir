
#
# RawDiskSeqs: an object that represents a collection of biological
# sequences on disk in RAW byte format; useful to maintain large
# genomes where you want to be able to extract any subseq.
#

- PerlClass	PirObject::RawDiskSeqs
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
fastafilename		single		string
fastamd5                single          string
fastaorigsize           single          int4
rawseqs                 array           <RawSeq>
totalsize               single          int4
tiedfilename            single          string

- EndFieldsTable
- Methods

our $RCS_VERSION='$Id: RawDiskSeqs.pir,v 1.2 2008/08/20 19:43:22 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub GetRawSeqById {
    my $self     = shift;
    my $id       = shift;
    my $class    = ref($self);

    die "This is an instance method.\n" unless $class;

    # Get index; build it if necessary, at first access.
    my $index = $self->{'_IdIndex_'};
    if (!defined($index)) {
        $index = $self->{'_IdIndex_'} = {};
        my $seqlist = $self->get_rawseqs() || [];
        foreach my $rawseqobj (@$seqlist) {
            my $objid = $rawseqobj->get_id();
            $index->{$objid}=$rawseqobj;
        }
    }

    # Get object from index
    $index->{$id};  # returns undef if it doesn't exist
}

sub TieToRawFileHandle {
    my $self     = shift;
    my $fh       = shift; # Read and/or write!
    my $filename = shift; # optional
    my $class    = ref($self);

    die "This is an instance method.\n" unless $class;

    my $totalsize = $self->get_totalsize() || 0; # 0 means unset, so no validation.

    #die "Error: the file '$filename' does not have the expected size of $totalsize.\n"
    #    unless ($totalsize == 0 || (-s $filename == $totalsize));

    #my $fh = new IO::File "+<$filename";  # The + means WRITE access too!
    #    or die "Cannot read from '$filename': $!\n";

    $fh->seek(0,2); # 2 is SEEK_END
    my $cursize = $fh->tell();
    die "Error: the filehandle's file does not have the expected size of $totalsize (got $cursize).\n"
        unless ($totalsize == 0 || ($cursize == $totalsize));

    my $rawseqs = $self->get_rawseqs() || [];
    foreach my $rawseq (@$rawseqs) {
        $rawseq->{'_tiedFh_'} = $fh;
    }

    $self->{'_tiedFh_'} = $fh;
    $self->set_tiedfilename($filename); # which can be undef

    1;
}

sub AddNewRawSeq {
    my $self     = shift;
    my $id       = shift || die "Need id?\n";
    my $faheader = shift || die "Need fasta header?\n";
    my $seq      = shift || die "Need seq?\n";

    my $class    = ref($self);
    die "This is an instance method.\n" unless $class;

    # Find current position at end of file
    my $outfh    = $self->{'_tiedFh_'}
        or die "Error: object not yet tied to a filehandle?!?\n";
    $outfh->seek(0,2); # 2 is SEEK_END
    my $curbyte = $outfh->tell();
    die "Error: filhandle not seekable?!?\n" if !defined $curbyte;
    my $previousend = $self->get_totalsize() || 0;
    die "Error: object's previous totalsize field ($previousend) is different from file's size ($curbyte).\n"
        if $previousend != $curbyte;

    # Write header
    my $fileid = ">$id\n";
    $outfh->syswrite($fileid);
    $curbyte += length($fileid);

    # Create seq object
    my $seqlen = length($seq);
    my $seqobj = new PirObject::RawSeq( id          => $id,
                                        fastaheader => $faheader,
                                        startoffset => $curbyte,
                                        seqlength   => $seqlen,
                                       );

    # Write seq data
    $outfh->syswrite($seq); $curbyte += $seqlen;
    $outfh->syswrite("\n"); $curbyte += length("\n");

    # Record info in object
    my $diskseqs = $self->get_rawseqs() || [];
    push(@$diskseqs,$seqobj);
    $self->set_rawseqs($diskseqs);
    $self->set_totalsize($curbyte);
    $self->{'_IdIndex_'}->{$id} = $seqobj if exists $self->{'_IdIndex_'};

    $self;
}
