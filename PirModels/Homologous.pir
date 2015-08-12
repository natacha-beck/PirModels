
#
# This is an object that can store the information about homologous protein identified by Blast
#

- PerlClass PirObject::Homologous
- InheritsFrom  PirObject
- FieldsTable

# Field name             Struct  Type            Comments
#---------------------- -------  --------------- -----------------------
similarprot              single  string          homologous protein
evalue                   single  string          E-Value given by Blast
origine                  single  string          Define gene origine can be pt,pt_cyano,mt,mt_alpha.

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Homologous.pir,v 1.4 2010/12/20 18:33:57 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

