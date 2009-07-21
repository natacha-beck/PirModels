
#
# This class contain hash of Item List for each RNA model
#
#
# $Id: MenuList.pir,v 1.1 2009/07/21 15:58:18 nbeck Exp $
#
# $Log: MenuList.pir,v $
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
OriName                 single          string          Name of block in Menufile
ModulList               hash            string          Modul list for each RNA
ItemSet                 hash            <ItemSet>       List of item block for each RNA
