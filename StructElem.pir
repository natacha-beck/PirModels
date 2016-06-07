
#
# Single element of a LinStruct
#


- PerlClass	PirObject::StructElem
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
elemId                  single          string
elemType                single          string          "LOOP" or "HELIX"
startposL               single          int4            starts at 0
elemLength              single          int4
startposR               single          int4            for right element if HELIX; starts at 0
isSearch                single          int4            1 if elem is searched else 0

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: StructElem.pir,v 1.3 2008/10/28 22:00:58 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

