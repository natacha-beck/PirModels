#
# A list of hit results; not much else for the moment.
#
#    $Id: SimpleHitList.pir,v 1.3 2007/07/13 21:44:50 riouxp Exp $
#
#    $Log: SimpleHitList.pir,v $
#    Revision 1.3  2007/07/13 21:44:50  riouxp
#    Improved time reporting.
#
#    Revision 1.2  2007/07/13 21:14:00  riouxp
#    Added timing info, for better logging.
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

- PerlClass	PirObject::SimpleHitList
- InheritsFrom	PirObject
- FieldsTable

# Field name		Sing/Array/Hash	Type		Comments
#---------------------- ---------------	---------------	-----------------------
preparetime             single          int4
searchtime              single          int4
timetaken               single          string          in seconds
hitlist                 array           <SimpleHit>

- EndFieldsTable
- Methods

