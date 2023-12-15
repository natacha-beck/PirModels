
#
# A module for storing Orfs with no gene corresponding.
#

- PerlClass PirObject::EmptyOrf
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct  Type                Comments
#---------------------- ------- ------------------- -----------------------
contigname              single  string              contigname
start                   single  int4                Start ORF
end                     single  int4                End ORF
strand                  single  int4                Strand of the ORF
evalue                  single  string              E-Value given by Blast for this ORF
intron                  single  int4                number of intron if overlappe an intron
phase                   single  int4                phase with precedent Exon
prefix                  single  string              Indication in order to annote intronical ORF
size                    single  int4                Lenght of ORF
seq                     single  string              The aa sequence of ORF
firstAA                 single  string              First amino acid
possible_start          array   string              List of possible start
all_possible_start      hash    string              List of possible start
similar_prot            single  string              Name protein that match with BLAST
notes                   array   string              An array of not that should be added on the startline
posHMMmatch             single  string              Indicate positions (in nt position) of HMMmodel match
allposHMMmatch          array   string              Indicate all positions (in nt position) of HMMmodel match
matchEndo               single  int4                Indicate if ORF match with endonuclease
isLong                  single  int4                Indicate if ORF is long

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: EmptyOrf.pir,v 1.6 2009/12/12 00:50:01 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

