
#
# This class contain hash of Item List for each RNA model
#
#
# $Id: Item.pir,v 1.2 2009/07/23 19:36:00 nbeck Exp $
#
# $Log: Item.pir,v $
# Revision 1.2  2009/07/23 19:36:00  nbeck
# Added -c Option, and change Usage.
#
# Revision 1.1  2009/07/21 15:58:18  nbeck
# Fusion between RNASpinner and RNAfinder.
#
#


- PerlClass	PirObject::Item
- InheritsFrom	PirObject
- FieldsTable

# Field name    		Sing/Array/Hash	Type		    Comments
#---------------------- ---------------	---------------	-----------------------
erpinArg                single          string          list of erpin argument
modelFile               single          string          file name of the model erpin
cutoff                  single          string          cutoff used by erpin
Label                   single          string          used for certain RNA (Intron)
AcId                    single          int4            number of anticodon element
module                  single          string          number identification for module, can be a list of number
modTab                  array           int4            number identification for module, can be a list of number
comment                 single          string          comment for menu
erpinMaskNums           array           string          Mask number used by erpin
ModelFile               single          string          Name of file contain non redundant model
lowest                  single          int4            The lowest mask number used by erpin
