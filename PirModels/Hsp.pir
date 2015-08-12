
#
# A simple container for XML Blast Output; based on NCBI's DTD.
#

- PerlClass PirObject::BlastOutput::Iteration::Hit::Hsp
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type            Comments
#---------------------- --------------- --------------- -----------------------
Hsp_num                 single          int8
Hsp_bit-score           single          string
Hsp_score               single          string
Hsp_evalue              single          string
Hsp_query-from          single          int8
Hsp_query-to            single          int8
Hsp_hit-from            single          int8
Hsp_hit-to              single          int8
Hsp_pattern-from        single          int8
Hsp_pattern-to          single          int8
Hsp_query-frame         single          int8
Hsp_hit-frame           single          int8
Hsp_identity            single          int8
Hsp_positive            single          int8
Hsp_gaps                single          int8
Hsp_align-len           single          int8
Hsp_density             single          int8
Hsp_qseq                single          string
Hsp_hseq                single          string
Hsp_midline             single          string

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Hsp.pir,v 1.3 2008/09/10 19:08:32 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub frac_identical { # as in BioPerl
  my $self = shift;

  my $id  = $self->get_Hsp_identity();
  my $len = $self->get_Hsp_align_len() || 1;

  return ($id/$len);
}

sub significance {
  my $self = shift;
  $self->Hsp_evalue(@_);
}

sub start {
  my $self = shift;
  $self->Hsp_query_from(@_);
}

sub end {
  my $self = shift;
  $self->Hsp_query_to(@_);
}
