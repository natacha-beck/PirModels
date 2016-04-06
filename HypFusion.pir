
#
# Give some information about hypothetic fusion gene
#

- PerlClass     PirObject::HypFusion
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct  Type                Comments
#---------------------- ------- ------------------- -----------------------
name                    single  string              Name of hypothetic fusion gene
start                   single  int4                Start of hypothetic fusion gene
end                     single  int4                End of hypothetic fusion gene

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: HypFusion.pir,v 2.3 2012/01/21 20:49:46 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

