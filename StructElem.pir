#
# Single element of a LinStruct
#
#    $Id: StructElem.pir,v 1.3 2008/10/28 22:00:58 nbeck Exp $
#
#    $Log: StructElem.pir,v $
#    Revision 1.3  2008/10/28 22:00:58  nbeck
#    Add field : isSearch.
#
#    Revision 1.2  2008/08/20 19:43:22  riouxp
#    Added CVS tracking variables.
#
#    Revision 1.1  2007/07/11 19:55:18  riouxp
#    New project. Initial check-in.
#
#    Added Files:
#        HMMweasel
#        HMMER2SearchEngine.pir LinStruct.pir PotentialResult.pir
#        RawDiskSeqs.pir RawSeq.pir ResultElement.pir SearchEngine.pir
#        SimpleHit.pir SimpleHitList.pir StructElem.pir
#

- PerlClass	PirObject::StructElem
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
elemId                  single          string
elemType                single          string          "LOOP" or "HELIX"
startposL               single          int4            starts at 0
elemLength              single          int4            
startposR               single          int4            for right element if HELIX; starts at 0
isSearch                single          int4            1 if elem is searched else 0

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: StructElem.pir,v 1.3 2008/10/28 22:00:58 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

