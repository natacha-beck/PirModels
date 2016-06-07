
#
# PirObject definition file for a RNA prediction
# This object is used by tRNASpinner and RNAfinder.
#


- PerlClass	PirObject::RNAPredictionList
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
BracketModel            single          string          Representation of uses bracket Model.
ConsensusModel          single          string          Representation of consensus.
Name                    single          string          Name of model
NumItem                 single          string          Number of Item
Label                   single          string          Label name
toComment               single          int4            If startline need to be in comment in Masterfile
rnapredictions          array          <RNAPrediction>  Each predicted RNA.


- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: RNAPredictionList.pir,v 1.3 2011/03/18 19:27:10 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

# None of the moment.
