#
# A simple container for XML Blast Output; based on NCBI's DTD.
#

- PerlClass	PirObject::BlastOutput::Iteration::Hit
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
Hit_num                 single          int8
Hit_id                  single          string
Hit_def                 single          string
Hit_accession           single          string
Hit_len                 single          int8
Hit_hsps                array           <Hsp>

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Hit.pir,v 1.4 2008/09/10 19:08:32 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

# This is compatible with BioPerl, where the significance of a
# hit was coded as being the significance of the top HSP
sub significance {
    my $self = shift;
    my $hsps = $self->get_Hit_hsps();
    die "Cannot find significance: No HSPs in hit!\n"
        unless @$hsps;
    $hsps->[0]->get_Hsp_evalue();
}

sub score {
    my $self = shift;
    my $hsps = $self->get_Hit_hsps();
    die "Cannot find score: No HSPs in hit!\n"
        unless @$hsps;
    $hsps->[0]->get_Hsp_bit_score();  # as in bioperl
}

