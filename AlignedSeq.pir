
#
# A simple containiner for a sequence in a multiple alignment
#

- PerlClass PirObject::AlignedSeq
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type            Comments
#---------------------- --------------- --------------- -----------------------
shortSeqId              single      string
seqId                   single      string
seqFastaRest            single      string
sequence                single      string
PP                      single      string

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: AlignedSeq.pir,v 1.5 2010/08/13 15:48:27 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub AsFasta {
  my $self = shift;

  my $class = ref($self) || $self;

  my $id   = $self->get_seqId()           || ("Anonymous-".scalar($self));
  my $rest = $self->get_seqFastaRest();
  my $seq  = $self->sequence();

  if (defined($rest) && $rest ne "") {
    $rest =~ s/^/ / unless $rest =~ m#^\s#;
  } else {
    $rest = "";
  }

  my $fasta_seq  = "";
  
  for (my $i=0;$i<length($seq);$i+=50) {
    my $remain  = length($seq) - $i;
    $fasta_seq .= substr($seq,$i, $remain < 50 ? $remain : 50)."\n";
    $fasta_seq =~ s/\./-/g;
  }
  my $text = ">$id\n$fasta_seq\n";
  $text;
}

sub AsPhylipN {
  my $self = shift;

  my $class = ref($self) || $self;

  my $id   = $self->get_seqId() || ("Anonymous-".scalar($self));
  my $seq  = $self->sequence();

  $id  = substr($id,0,10) if    length($id) > 10;
  $id .= " "              while length($id) < 13;

  my $text = $id;  # 15 characters
  #$text .= "$seq\n";

  for (my $i=0;$i<length($seq);$i+=50) {
    my $remain = length($seq) - $i;
    my $subseq = substr($seq,$i, $remain < 50 ? $remain : 50);
    foreach my $space ( 40, 30, 20, 10 ) {
      next if $space >= length($subseq);
      substr($subseq,$space,0) = " ";
    }
    $text .= (" " x 13) if $i > 0;
    $text .= "$subseq\n";
  }

  $text;
}

