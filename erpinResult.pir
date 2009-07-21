
#
# This class represent erpin result.
#

- PerlClass	PirObject::erpinResult
- InheritsFrom	PirObject
- FieldsTable

# Field name    		Sing/Array/Hash	Type		     Comments
#---------------------- ---------------	---------------  -----------------------
structure               single          string           Alignement structure
bracket                 single          string           Bracket structure
consensus               single          string           Consensus structure
fileName                single          string           Name of file used for research
structureLen            single          int4             Structure length
SequenceLen             single          int4             Sequence length
NumItem                 single          string           Item number
Label                   single          string           Label name
modTab                  array           int4             number identification for module, can be a list of number
Alignments              array           <erpinAlignment> Contain all information about each alignment
