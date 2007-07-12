#
# Represents the raw information about a search engine's
# hit to a molecular sequence.
#
#    $Id: SimpleHit.pir,v 1.2 2007/07/12 20:21:49 riouxp Exp $
#
#    $Log: SimpleHit.pir,v $
#    Revision 1.2  2007/07/12 20:21:49  riouxp
#    Added field for storing the exact alignment as reported
#    by the search engine.
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

- PerlClass	PirObject::SimpleHit
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
targetId                single          string
hitStart                single          int4            Convention: start < stop always
hitStop                 single          int4
hitStrand               single          string          "+" or "-"
hitAlign                single          string          E.g. "AAGTCG--TGATG--AG"
hitScore                single          string
hitEvalue               single          string

- EndFieldsTable
- Methods

