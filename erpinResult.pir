
#
# This class represent erpin result.
#

- PerlClass	PirObject::erpinResult
- InheritsFrom	PirObject
- FieldsTable

# Field name    		Sing/Array/Hash	Type		     Comments
#---------------------- ---------------	---------------  -----------------------
structure               single          string           Alignement structure
StructArray             array           string           Structure split in elem
bracket                 single          string           Bracket structure
BracketLogArray         array           string           Bracket structure split in elem
consensus               single          string           Consensus structure
fileName                single          string           Name of file used for research
structureLen            single          int4             Structure length
SequenceLen             single          int4             Sequence length
NumItem                 single          string           Item number
Label                   single          string           Label name
comment                 single          string           A comment
modTab                  array           int4             number identification for module, can be a list of number
Alignments              array           <erpinAlignment> Contain all information about each alignment
OriSol                  single          int4             Nb of original solution
OriFusSol               single          int4             Nb of original unique solution when model was fusioned.
time                    single          string           time for run erpin
maxBitLength            array           int4             Conserved maxBitLen (len of each elem...) little bit wrong for non search elem.
elemLength              array           int4             Conserved element length in order.
erpinMaskNums           array           int4             Elem searched by erpin
modelFile               single          string           Model used in oredre to run erpin
gaptoend                single          string           list of elements where gaps must be placed at the end
commentForMFa           single          string           comment for MFannot
toComment               single          int4             if startline need to be in comment in Masterfile
