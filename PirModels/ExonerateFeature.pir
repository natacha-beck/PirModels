
#
# Feature from an Exonerate report.
#

- PerlClass PirObject::ExonerateFeature
- InheritsFrom  PirObject
- FieldsTable

# Field name        Sing/Array/Hash Type        Comments
#---------------------- --------------- --------------- -----------------------
seqname                 single          string
source                  single          string
feature                 single          string
start                   single          int4
end                     single          int4
score                   single          string
strand                  single          string
frame                   single          string
attributes              single          string

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: ExonerateFeature.pir,v 1.2 2008/08/19 20:32:05 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub FillFromLine {
    my $self = shift;
    my $line = shift;
    $line =~ s/\s*$//;
    my ($seqname,$source,$feature,$start,$end,$score,$strand,$frame,$attributes)
        = split(/\s+/,$line,9);
    $self->set_seqname($seqname);
    $self->set_source($source);
    $self->set_feature($feature);
    $self->set_start($start);
    $self->set_end($end);
    $self->set_score($score);
    $self->set_strand($strand);
    $self->set_frame($frame);
    $self->set_attributes($attributes);
}

