
#
# This is an object that can store the information about a protein given by esl-translate
# and after blast : it means the different ORFs, for example cob has 3 differents
# ORF in many place
#

- PerlClass     PirObject::EslBlastProt
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct  Type                Comments
#---------------------- ------- ------------------- -----------------------
name                    single  string              Name of the gene predicted with esl-translate and blast
contigname              single  string              Contig name where the prediction and blast have been made
hypfusiongene           single  string              Name of the gene with which it is merged
frameshift              single  int4                A boolean indicate if the gene presented a frameshift
orfs                    array   <Orf>               Array containing all the ORF (predicted by esl-translate and confirmed by blast) for this protein
homologous              array   <Homologous>        Array containing best homologous protein (predicted by Blast)
origine                 single  string              Define gene origine can be pt,pt_cyano,mt,mt_alpha.

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: EslBlastProt.pir,v 1.8 2010/12/20 18:33:57 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

