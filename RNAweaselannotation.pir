
#
# A single annotation find by RNAweasel.
#

- PerlClass PirObject::RNAweaselannotation
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct  Type                Comments
#---------------------- ------- ------------------- -----------------------
seqinformation          single  string              Name of the sequence having tRNA
tRNA_number             single  int4                Number of the tRNA in the output
strand                  single  string              Strand
begin                   single  int4                Begining of the tRNA in the sequence
begin_ac                single  int4                Begening of Anticodon
end                     single  int4                End of the tRNA in the sequence
anti_codon              single  string              Anti codon  
Evalue                  single  string              E-value for the prediction of this tRNA 

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: RNAweaselannotation.pir,v 1.3 2008/08/19 20:32:05 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

