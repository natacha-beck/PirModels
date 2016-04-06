
#
# Object that can contain exon information.
#

- PerlClass     PirObject::Exon
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct  Type                Comments
#---------------------- ------- ------------------- -----------------------
exonname                single  string              Exon name
dnastart                single  int4                Start exon on dna sequence
dnaend                  single  int4                End exon on dna sequence
strand                  single  int4                Strand
protstart               single  int4                Start exon on proteic sequence, the first position of protein is 1
protend                 single  int4                End exon on proteic sequence, if an aa is split by an intron the protend is before the aa who is split
frameshiftsize          single  int4                Define size of frameshift
insertion               single  int4                length of insertion in order to add comment
exoscore                single  int4                raw score defined by exonerate
FirstExoMatch           single  int4                Position of the first match with Exonerate for this C4 report.

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Exon.pir,v 1.8 2010/07/02 15:12:13 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

