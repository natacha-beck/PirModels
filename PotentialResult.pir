#
# A structure for maintaining a potential result
#
#    $Id: PotentialResult.pir,v 1.3 2007/07/18 21:25:06 riouxp Exp $
#
#    $Log: PotentialResult.pir,v $
#    Revision 1.3  2007/07/18 21:25:06  riouxp
#    Added methods and fields needed to build solutions made from pieces of
#    other solutions (for HWcombiner).
#
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
solutionStrand          single          string          "+" or "-", or "*" when mixed
numMatches              single          int4
combinedscore           single          string
canbealigned            single          string          undef, "", 0, or 1.

elementlist             array           <ResultElement>

matchStructStart        single          int4
matchStructStop         single          int4

numPieces               single          int4            For solutions in pieces, how many there are

- EndFieldsTable

- Methods

sub UpdateMatchStructStartAndStop {
    my $self = shift;

    my $elemlist = $self->get_elementlist();
    my ($min,$max) = (999999,0); # STRUCTURE positions, not sequence ones!
    foreach my $elem (@$elemlist) {
        my $type   = $elem->get_elemType();
        next unless $type eq "MATCH";
        my $elemStart = $elem->get_elemStart();
        my $elemStop  = $elem->get_elemStop();
        $min = $elemStart if $elemStart < $min;
        $max = $elemStop  if $elemStop  > $max;
    }

    $self->set_matchStructStart($min);
    $self->set_matchStructStop($max);
    $self;
}

sub GetMatchStructStartAndStop {
    my $self = shift;
    my $start = $self->get_matchStructStart();
    if (!defined($start)) { # auto update
        $self->UpdateMatchStructStartAndStop();
        $start = $self->get_matchStructStart();
    }
    my $stop = $self->get_matchStructStop();
    ($start,$stop);
}
