
#
# This class contain hash of Item List for each RNA model
#
#
# $Id: Item.pir,v 1.7 2011/01/25 21:15:51 nbeck Exp $
#
# $Log: Item.pir,v $
# Revision 1.7  2011/01/25 21:15:51  nbeck
# Removed inclusion, added comments for MFannot, changed output format.
#
# Revision 1.6  2011/01/20 22:18:10  nbeck
# Added function for model fusion (for tRNA).
#
# Revision 1.5  2009/09/01 21:03:48  nbeck
# Some esthetic modification.
#
# Revision 1.4  2009/08/20 21:31:25  nbeck
# Added resume and NoSolution file.
#
# Revision 1.3  2009/07/24 22:01:09  nbeck
# Added parallelization of erpin.
#
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
erpinOut                single          string          erpin outfile
erpinErr                single          string          erpin errfile
time                    single          string          time for run erpin
gaptoend                single          string          list of elements where gaps must be placed at the end
commentForMFa           single          string          comment for MFannot
