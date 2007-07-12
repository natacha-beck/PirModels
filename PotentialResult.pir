#
# A structure for maintaining a potential result
#
#    $Id: PotentialResult.pir,v 1.2 2007/07/12 20:21:24 riouxp Exp $
#
#    $Log: PotentialResult.pir,v $
#    Revision 1.2  2007/07/12 20:21:24  riouxp
#    Added field for FASTA reporting.
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

- PerlClass	PirObject::PotentialResult
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
sequenceId              single          string
sequenceName            single          string
resultNumber            single          string          e.g. "2/4" meaning '2 of 4'
solutionStrand          single          string          "+" or "-"
numMatches              single          int4
combinedscore           single          string
canbealigned            single          string          undef, "", 0, or 1.

elementlist             array           <ResultElement>

- EndFieldsTable

- Methods


