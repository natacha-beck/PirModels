
#
# A simple container for XML Blast Output; based on NCBI's DTD.
#

- PerlClass PirObject::BlastOutput::Parameter
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type            Comments
#---------------------- --------------- --------------- -----------------------
Parameters_matrix       single          string
Parameters_expect       single          string
Parameters_include      single          string
Parameters_sc-match     single          int8
Parameters_sc-mismatch  single          int8
Parameters_gap-open     single          int8
Parameters_gap-extend   single          int8
Parameters_filter       single          string
Parameters_pattern      single          string
Parameters_entrez-query single          string

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Parameters.pir,v 1.2 2008/08/20 19:43:23 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

