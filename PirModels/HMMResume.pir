
#
# Parser for HMM result.
#

- PerlClass	PirObject::HMMResume
- InheritsFrom	PirObject
- FieldsTable

# Field name		    Sing/Array/Hash	Type		    Comments
#---------------------- ---------------	---------------	-----------------------
fEvalue                 single          int4            full evalue
fScore                  single          int4            full score
fBias                   single          int4            full bias
bEvalue                 single          int4            best evalue
bScore                  single          int4            best score
bBias                   single          int4            best bias
exp                     single          int4            
NumAli                  single          int4            number of ali
SequenceId              single          string          identification number
Description             single          string          
BeforeThresh            single          int4            1 if before HMM threshold else 0
alignments              single          <HMMAli>
SeqIdAndDesc            single          string          full header

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: HMMResume.pir,v 1.4 2011/03/04 20:40:51 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

