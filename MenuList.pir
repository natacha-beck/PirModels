
#
# This class contain hash of Item List for each RNA model
#
#
# $Id: MenuList.pir,v 1.3 2009/08/06 21:03:05 nbeck Exp $
#
# $Log: MenuList.pir,v $
# Revision 1.3  2009/08/06 21:03:05  nbeck
# Fixed conflicts in RNAfinderFileForMenu.pir MenuList.pir
#
# Revision 1.2  2009/07/23 19:36:00  nbeck
# Added -c Option, and change Usage.
#
# Revision 1.1  2009/07/21 15:58:18  nbeck
# Fusion between RNASpinner and RNAfinder.
#
#

- PerlClass	PirObject::MenuList
- InheritsFrom	PirObject
- FieldsTable

# Field name    		Sing/Array/Hash	Type		    Comments
#---------------------- ---------------	---------------	-----------------------
name                    single          string          Name of model
Comment                 single          string          Comment for model
OriName                 single          string          Name of block in Menufile
ModulList               hash            string          Modul list for each RNA
Set                     hash            <ItemSet>       List of item block for each RNA
