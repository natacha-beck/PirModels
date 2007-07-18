#
# This is used in many different contexts to represent
# how a match was found between an element to search
# and a molecular sequence; this object also contains a
# copy of some of the structural information for the element.
#
#    $Id: ResultElement.pir,v 1.2 2007/07/18 21:26:20 riouxp Exp $
#
#    $Log: ResultElement.pir,v $
#    Revision 1.2  2007/07/18 21:26:20  riouxp
#    Added field "piecenumber". Removed obsolete field "distancewarnings".
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

- PerlClass	PirObject::ResultElement
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
elementId               single          string
elemStart               single          int4
elemStop                single          int4
elemType                single          string

seqStart                single          int4
seqStop                 single          int4
score                   single          string
evalue                  single          string

sequence                single          string

piecenumber             single          int4             When part of a solution in pieces

- EndFieldsTable
- Methods

