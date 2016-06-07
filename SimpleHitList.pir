
#
# A list of hit results; not much else for the moment.
#

- PerlClass	PirObject::SimpleHitList
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
preparetime             single          int4
searchtime              single          int4
timetaken               single          string          in seconds
hitlist                 array           <SimpleHit>

- EndFieldsTable
- Methods

our $RCS_VERSION='$Id: SimpleHitList.pir,v 1.4 2008/08/20 19:43:22 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

