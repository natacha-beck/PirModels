#
# A simple containiner for a multiple alignment.
#

- PerlClass	PirObject::MultAlign
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
alignId			single		string          # Optional; can be filename
alignedSeqs		array		<AlignedSeq>

- EndFieldsTable

- Methods

sub NumSequences {
    my $self = shift;
    my $class = ref($self) || $self;

    die "Not a class method.\n" if $self eq $class;

    my $seqlist = $self->get_alignedSeqs() || [];
    scalar(@$seqlist);
}

sub AlignmentLength {
    my $self = shift;
    my $class = ref($self) || $self;

    die "Not a class method.\n" if $self eq $class;

    my $seqlist = $self->get_alignedSeqs() || [];
    return 0 if !@$seqlist;
    my $seqobj = $seqlist->[0];  # first one
    return length($seqobj->get_sequence() || "");
}

sub GuessType {
    my $self = shift;
    my $class = ref($self) || $self;

    die "Not a class method.\n" if $self eq $class;

    my $seqlist = $self->get_alignedSeqs() || [];
    return "Unknown" if !@$seqlist;

    my $seqobj = $seqlist->[0];  # first one
    my $seq    = $seqobj->get_sequence() || "";
    $seq =~ tr/A-Za-z//cd;
    my $origlen = length($seq);
    $seq =~ tr/ACGTacgtNn\-//d;
    return "nucleotide" if length($seq) < .1 * $origlen;
    return "protein";
}
