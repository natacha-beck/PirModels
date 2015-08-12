
#
# Each iteration of jackhmmer.
#

- PerlClass PirObject::HMMIteration
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type            Comments
#---------------------- --------------- --------------- -----------------------
number                  single          int4            Which iteration
NbResUpperTresh         single          int4            number of resume with treshold upper cutoff
QueryModel              single          string          Define model.
TargetSequences         single          string
MSVFilter               single          string
BiasFilter              single          string
VitFilter               single          string
FwdFilter               single          string
SearchSpace             single          string
domZ                    single          string
CPUTime                 single          string
McSec                   single          string
IncludedMSA             single          string
ModelSize               single          string
resume                  array           <HMMResume>

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: HMMIteration.pir,v 2.2 2011/03/04 20:40:51 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);
