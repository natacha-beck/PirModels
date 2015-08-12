
#
# A simple container for XML Blast Output; based on NCBI's DTD.
#

- PerlClass PirObject::BlastOutput
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type            Comments
#---------------------- --------------- --------------- -----------------------
BlastOutput_program     single          string
BlastOutput_version     single          string
BlastOutput_reference   single          string
BlastOutput_db          single          string
BlastOutput_query-ID    single          string
BlastOutput_query-def   single          string
BlastOutput_query-len   single          int8
BlastOutput_query-seq   single          string
BlastOutput_param       single          <Parameters>
BlastOutput_iterations  array           <Iteration>
BlastOutput_mbstat      single          <Statistics>

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: BlastOutput.pir,v 1.2 2008/08/20 19:43:22 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

