
#
# This is an object that can store the information about an ORF
# All these information are given by flip and predicted.
#


- PerlClass	PirObject::Orf
- InheritsFrom	PirObject
- FieldsTable

# Field name            Struct  Type                Comments
#---------------------  ------  ------------------- ---------------------
start                   single  int4                Start ORF
startBlast              single  int4                Start of match blast
end                     single  int4                End ORF
strand                  single  int4                Strand of the ORF
evalue                  single  string              E-Value given by Blast for this ORF
hsps                    array   <Hsp_query_sbjct>   All the HSP given by blast
protein                 single  string              The protein blasted against this ORF

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Orf.pir,v 1.7 2008/09/12 18:32:20 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

