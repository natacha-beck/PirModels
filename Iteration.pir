
#
# A simple container for XML Blast Output; based on NCBI's DTD.
#

- PerlClass PirObject::BlastOutput::Iteration
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type            Comments
#---------------------- --------------- --------------- -----------------------
Iteration_iter-num      single          int8
Iteration_query-ID      single          string
Iteration_query-def     single          string
Iteration_query-len     single          int8
Iteration_hits          array           <Hit>
Iteration_stat          single          <Statistics>
Iteration_message       single          string

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Iteration.pir,v 1.2 2008/08/20 19:43:23 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

