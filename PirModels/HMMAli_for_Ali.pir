
#
# Used in order to parse alignement output of HMMsearch.
#

- PerlClass	PirObject::HMMAli_for_Ali
- InheritsFrom	PirObject
- FieldsTable

# Field name		    Sing/Array/Hash	Type		     Comments
#---------------------- ---------------	---------------	 -----------------------
id                      single          string           identification name
header                  single          string           full header
start_ori               single          int4             original start found in default hmmsearch
start                   single          int4             start pos with dash renoved
end_ori                 single          int4             original end found in default hmmsearch
end                     single          int4             end pos with dash renoved
ali_seq                 single          string           alignement sequence
ali_hmm                 single          string           statistic sequence

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: HMMAli_for_Ali.pir,v 1.1 2011/03/25 23:25:36 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

