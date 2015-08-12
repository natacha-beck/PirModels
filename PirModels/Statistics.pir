#
# A simple container for XML Blast Output; based on NCBI's DTD.
#

- PerlClass	PirObject::BlastOutput::Iteration::Statistics
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
Statistics_db-num       single          int8
Statistics_db-len       single          int8
Statistics_hsp-len      single          int8
Statistics_eff-space    single          string
Statistics_kappa        single          string
Statistics_lambda       single          string
Statistics_entropy      single          string

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Statistics.pir,v 1.2 2008/08/20 19:43:23 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

