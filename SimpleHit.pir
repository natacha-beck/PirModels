
#
# Represents the raw information about a search engine's
# hit to a molecular sequence.
#


- PerlClass	PirObject::SimpleHit
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
targetId                single          string
hitStart                single          int4            Convention: start < stop always
hitStop                 single          int4
hitStrand               single          string          "+" or "-"
hitAlign                single          string          E.g. "AAGTCG--TGATG--AG"
hitScore                single          string
hitEvalue               single          string

- EndFieldsTable
- Methods

our $RCS_VERSION='$Id: SimpleHit.pir,v 1.3 2008/08/20 19:43:22 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

