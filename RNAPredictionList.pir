
#
# PirObject definition file for a tRNA prediction
# This object is used by tRNASpinner.
#
#    $Id: RNAPredictionList.pir,v 1.1 2008/10/28 21:57:23 nbeck Exp $
#
#    $Log: RNAPredictionList.pir,v $
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
rnapredictions          array          <RNAPrediction>  Each predicted RNA.
          

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: RNAPredictionList.pir,v 1.1 2008/10/28 21:57:23 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

# None of the moment.
