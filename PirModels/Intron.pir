
#
# Object that can contain exon
#
#    $Id: Intron.pir,v 1.4 2009/03/24 21:07:26 nbeck Exp $
#
#    $Log: Intron.pir,v $
#    Revision 1.4  2009/03/24 21:07:26  nbeck
#    Add new fields in order to add information about insertion.
#
#    Revision 1.3  2008/08/19 20:32:05  riouxp
#    All mfannot PIR files: added CVS revision tracking variables;
#    obsessively adjusted spacing and blank lines.
#
#    Revision 1.2  2008/08/13 21:05:26  nbeck
#    Add new fields to support mini-exons identification.
#

- PerlClass     PirObject::Intron
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct  Type                    Comments
#---------------------- ------- -------------------     -----------------------
intronname              single  string                  Name of the intron
start                   single  int4                    Start intron
end                     single  int4                    End intron
strand                  single  int4                    Strand
intronpos               single  int4                    Position of intron in proteic sequence
phase                   single  int4                    0 if intron doesn't split a tri-nt, 1 or 2 if intron split the tri-nt
type                    single  string                  Group of intron
idbyRNAw                single  <AnnotPairCollection>   A list of AnnotPair
comment                 single  string                  A comment add to the annotation
exoStart                single  int4                    End of previous C4 report when we have multiple C4 for 1 gene
exoEnd                  single  int4                    Start of next c4 report when we have multiple C4 for 1 gene

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Intron.pir,v 1.4 2009/03/24 21:07:26 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

