#
# Single element of a LinStruct
#
#    $Id: StructElem.pir,v 1.1 2007/07/11 19:55:18 riouxp Exp $
#
#    $Log: StructElem.pir,v $
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

- EndFieldsTable

- Methods


