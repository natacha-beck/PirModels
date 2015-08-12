
#
# HSP given by BLAST.
#

- PerlClass PirObject::Hsp_query_sbjct
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct  Type                Comments
#---------------------- ------- ------------------- -----------------------
start_q                 single  int4            Start HSP query 
end_q                   single  int4            End HSP query
start_s                 single  int4            Start HSP subject   
end_s                   single  int4            End HSP subject
query_string            single  string          String of query
subject_string          single  string          String of subject
homology_string         single  string          String of homology
strand                  single  int4            strand HSP  

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Hsp_query_sbjct.pir,v 1.3 2008/08/19 20:32:05 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

