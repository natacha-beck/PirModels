#
# A structure for maintaining a potential result
#
#    $Id: PotentialResult.pir,v 1.4 2007/07/19 18:27:38 riouxp Exp $
#
#    $Log: PotentialResult.pir,v $
#    Revision 1.4  2007/07/19 18:27:38  riouxp
#    moved elementlist to end of object definition. Added FASTA dump support
#    and a utility routine to get the set of star/stop pairs for each piece
#    of a solution in pieces.
#
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

matchStructStart        single          int4
matchStructStop         single          int4

numPieces               single          int4            For solutions in pieces, how many there are

elementlist             array           <ResultElement>


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

sub GetPiecesSeqCoverage {
    my $self = shift;

    my $numPieces = $self->get_numPieces() || 1;
    my $elemlist  = $self->get_elementlist();

    if ($numPieces == 1) {
        my $firstelem = $elemlist->[0];
        my $lastelem  = $elemlist->[-1];
        my ($start,$stop) = ($firstelem->get_seqStart(),$lastelem->get_seqStop());
        return [ [ $start, $stop, ] ]; # a single piece
    }

    my $startstoplist = [];
    my $prevPiece = -999; # arbitrary OTHER number
    foreach my $elem (@$elemlist) {
        my $piecenumber = $elem->get_piecenumber();
        if (!defined($piecenumber)) { # zero is a legal piece number
            $prevPiece = -999; # reset; we're probably in an INTERSPACE element
            next;
        }
        my ($start,$stop) = ($elem->get_seqStart(),$elem->get_seqStop());
        if ($piecenumber != $prevPiece) { # new piece?
            push(@$startstoplist, [ $start, $stop ]);
            $prevPiece=$piecenumber;
            next;
        }
        # Same piece? Update just stop
        $startstoplist->[-1]->[1] = $stop;
    }

    $startstoplist;
}

sub AsFancyFasta {
    my $res             = shift; # This is actually $self !
    my $dopad           = shift || 0;  # option; if true pad element with "-" if necessary
    my $doshorten       = shift || 0;  # option; if true shorten element with nnnnnn if necessary
    my $whattolowercase = shift || ""; # option; what element to highlight in lowercase.
    my $importantelems  = shift || {}; # optional hash: elements labeled "important"

    my $strand   = $res->get_solutionStrand();
    my $elemlist = $res->get_elementlist();
    my $seqname  = $res->get_sequenceName();
    my $numelem  = $res->get_numMatches();
    my $score    = $res->get_combinedscore();
    my $resnumber= $res->get_resultNumber();
    my $numPieces= $res->get_numPieces() || 1;

    # Build the FASTA header

    my ($seqId,$rest)  = ($seqname =~ m#^>\s*(\S+)\s*(.*)#);
    $rest = " $rest" if $rest;

    my $startstoplist = $res->GetPiecesSeqCoverage();
    my $text_intervals = "";
    foreach my $startstop (@$startstoplist) {
        my ($start,$stop) = @$startstop;
        $start++;$stop++; # show as biological coordinates
        $text_intervals .= "," if $text_intervals;
        $text_intervals .= "($start,$stop)";
    }

    my $head = ">$seqId$text_intervals R=$resnumber N=$numelem S=$score$rest\n";

    # Build the sequence data, padded and adjusted if necessary

    my @seqs = (); # segments of sequences
    foreach my $elem (@$elemlist) {
        my $elemId      = $elem->get_elementId();
        my $seq         = $elem->get_sequence();
        my $type        = $elem->get_elemType();
        my $structstart = $elem->get_elemStart();
        my $structstop  = $elem->get_elemStop();
        my $structlen   = abs($structstart-$structstop)+1;

        if ($dopad) {
            while (length($seq) < $structlen) {
                if ($type eq "PREFIX") {
                    $seq = "-$seq";
                } elsif ($type eq "SUFFIX") {
                    $seq .= "-";
                } else {
                    substr($seq,int(length($seq)/2),0) = "-";
                }
            }
        }

        if ($whattolowercase) {
            $seq = lc $seq if
                ($type eq "MATCH"    && $whattolowercase =~ m/m/i) ||
                ($type eq "PREFIX"   && $whattolowercase =~ m/p/i) ||
                ($type eq "SUFFIX"   && $whattolowercase =~ m/s/i) ||
                ($type eq "INTERNAL" && $whattolowercase =~ m/i/i) ||
                ($type eq "MATCH"    && $whattolowercase =~ m/\+/ && $importantelems->{$elemId});
        }

        if ($doshorten && length($seq) > $structlen) {
            my $char = $type eq "MATCH" ? "N" : "n";
            my $remain = $structlen - 6;
            $remain = 0 if $remain < 0;
            my $remainL = int($remain/2); my $remainR = $remain-$remainL;
            my $left  = $remainL ? substr($seq,0,$remainL) : "";
            my $right = $remainR ? substr($seq,-$remainR)  : "";
            $seq = $left . ($char x ($structlen-$remain)) . $right;
        }

        push (@seqs,$seq);
    }

    # Return FASTA sequence record

    return $head . join("\n",@seqs) . "\n";
}
