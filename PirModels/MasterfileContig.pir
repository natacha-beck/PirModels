
#
# MasterfileContig : a container for a parsed masterfile's contig.
#

- PerlClass PirObject::MasterfileContig

- InheritsFrom  PirObject

- FieldsTable

# Field name            Struct          Type            Comments
#---------------------- --------------- --------------- -----------------------
name                    single          string          Fasta ID after ">"
namecomments            single          string          Comments on ">" line
sequence                single          string          Raw sequence data WITH SPECIAL CHARS
sequencelength          single          int4            Number of bases in contig
geneticcode             single          int4            NCBI genetic code
annotations             array           <AnnotPair>     All annotations in this contig

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: MasterfileContig.pir,v 1.5 2011/01/20 21:50:24 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);
