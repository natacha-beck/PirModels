
#
# This class contain hash of Item List for each RNA model
#
#
# $Id: MenuList.pir,v 1.6 2011/02/02 21:34:45 nbeck Exp $
#
# $Log: MenuList.pir,v $
# Revision 1.6  2011/02/02 21:34:45  nbeck
# Changed way to make models fusion, removed inclusion.
#
# Revision 1.5  2011/01/20 22:18:10  nbeck
# Added function for model fusion (for tRNA).
#
# Revision 1.4  2009/11/07 00:21:40  nbeck
# Changed output format.
#
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
Order                   single          int4            In order to sort RNA for output
OriName                 single          string          Name of block in Menufile
ToFus                   array           string          For example "0,1,tRNA" means that item 0 and 1 are joined and named tRNA for make more than 1 fusion put ";" between instruction "0,1,tRNA;2,3,tRNA2"
ModulList               hash            string          Modul list for each RNA
Set                     hash            <ItemSet>       List of item block for each RNA

