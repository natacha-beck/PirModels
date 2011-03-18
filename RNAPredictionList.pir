
#
# PirObject definition file for a RNA prediction
# This object is used by tRNASpinner and RNAfinder.
#
#    $Id: RNAPredictionList.pir,v 1.3 2011/03/18 19:27:10 nbeck Exp $
#
#    $Log: RNAPredictionList.pir,v $
#    Revision 1.3  2011/03/18 19:27:10  nbeck
#    Added option in order to annot gene in comment for AnnotPair.
#
#    Revision 1.2  2009/07/21 15:58:18  nbeck
#    Fusion between RNASpinner and RNAfinder.
#
#    Revision 1.1  2008/10/28 21:57:23  nbeck
#    Initial check-in.
#
#    Revision 1.2  2008/08/20 19:43:23  riouxp
#    Added CVS tracking variables.
#
#    Revision 1.1  2008/08/06 18:31:57  riouxp
#    Used by tRNASpinner.
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
