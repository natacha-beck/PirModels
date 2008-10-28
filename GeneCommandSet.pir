
#
# This class represents the content of a configuration
# file used by XXXX; 
#
# See also the encapsulating object, <ConfigFile>
#
#     $Id: GeneCommandSet.pir,v 1.1 2008/10/28 21:57:23 nbeck Exp $
#
#     $Log: GeneCommandSet.pir,v $
#     Revision 1.1  2008/10/28 21:57:23  nbeck
#     Initial check-in.
#
#

- PerlClass	PirObject::GeneCommandSet
- InheritsFrom	PirObject
- FieldsTable

# Field name		    Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
debug                   single          string          any perl true/false
genename		        single		    string		    genename
intel                   single          string          Define comportement of program
modelList               hash            string          key = model_name
commandList             hash            string          key = command_name

- EndFieldsTable
- Methods

our $DEBUG = 0; # class global; debug can also be turned on for each object, see above
our $RCS_VERSION='$Id: GeneCommandSet.pir,v 1.1 2008/10/28 21:57:23 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub set_debug {
    my $self = shift;
    $self->debug(@_);
}

sub debug {
    my $self = shift;
    return $self->AUTO_debug() unless @_;
    my $modelList = $self->get_modelList();
    foreach my $genecom (values %$modelList) {
        $genecom->set_debug(@_);
    }
    $self->AUTO_debug(@_);
}
