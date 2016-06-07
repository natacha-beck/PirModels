
#
# A simple containiner for a multiple alignment.
#

- PerlClass	PirObject::MultAlign
- InheritsFrom	PirObject
- FieldsTable

# Field name		    Sing/Array/Hash	Type		    Comments
#---------------------- ---------------	---------------	-----------------------
alignId			        single		string               # Optional; can be filename
consensus               single      string               Consensus of aligned sequence
PP_cons                 single      string               STOCKHOLM percent
alignedSeqs		        array		<AlignedSeq>

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: MultAlign.pir,v 1.4 2010/01/28 21:44:18 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub NumSequences {
    my $self = shift;
    my $class = ref($self) || $self;

    die "Not a class method.\n" if $self eq $class;

    my $seqlist = $self->get_alignedSeqs() || [];
    scalar(@$seqlist);
}

sub AlignmentLength {
    my $self = shift;
    my $class = ref($self) || $self;

    die "Not a class method.\n" if $self eq $class;

    my $seqlist = $self->get_alignedSeqs() || [];
    return 0 if !@$seqlist;
    my $seqobj = $seqlist->[0];  # first one
    return length($seqobj->get_sequence() || "");
}

sub GuessType {
    my $self = shift;
    my $class = ref($self) || $self;

    die "Not a class method.\n" if $self eq $class;

    my $seqlist = $self->get_alignedSeqs() || [];
    return "Unknown" if !@$seqlist;

    my $seqobj = $seqlist->[0];  # first one
    my $seq    = $seqobj->get_sequence() || "";
    $seq =~ tr/A-Za-z//cd;
    my $origlen = length($seq);
    $seq =~ tr/ACGTacgtNn\-//d;
    return "nucleotide" if length($seq) < .1 * $origlen;
    return "protein";
}

sub get_consensus {
    my $self = shift;

    my $consensus = $self->AUTO_get_consensus();
    return $consensus if $consensus;

    $consensus = $self->MakeConsensus();
    $self->set_consensus($consensus);

    $consensus;
}

sub MakeConsensus {
    my $self = shift;

    my $alignedSeqs       = $self->get_alignedSeqs();
    my $Info_for_each_pos = {};
    my $align_len         = $self->AlignmentLength();
    my $consensus         = "";
    my $nb_ali            = 0;

    foreach my $aligned_seq (@$alignedSeqs) {
        my $seq = $aligned_seq->get_sequence();
           $seq = uc($seq);
        my @nt_by_pos = split(//, $seq);
        for (my $i = 0; $i < $align_len; $i++ ) {
            my $nt   = $nt_by_pos[$i];
            $Info_for_each_pos->{$i}->{$nt}++;
        }
        $nb_ali++;
    }

    for (my $i = 0; $i < $align_len; $i++ ) {
        my $nt_for_this_pos = $Info_for_each_pos->{$i};
        my $nt_max    = "";
        my $max_value = 0;
        foreach my $nt (keys %$nt_for_this_pos) {
            my $val = $nt_for_this_pos->{$nt};
            $max_value = ( $nt_for_this_pos->{$nt} > $max_value ? $nt_for_this_pos->{$nt} : $max_value);
            $nt_max = $nt if $nt_for_this_pos->{$nt} == $max_value;
        }
        my $max_pourcent = ($max_value * 100 / $nb_ali);
        if (!($max_pourcent >= 70)) {
             my $nb_A = $nt_for_this_pos->{"A"} || 0;
             my $nb_T = $nt_for_this_pos->{"T"} || 0;
             my $nb_C = $nt_for_this_pos->{"C"} || 0;
             my $nb_G = $nt_for_this_pos->{"G"} || 0;
             my $pourcent_AG = ($nb_A + $nb_G) * 100 / $nb_ali;
             my $pourcent_TC = ($nb_T + $nb_C) * 100 / $nb_ali;
             ($max_pourcent,$nt_max) = ($pourcent_AG,"R")  if $pourcent_AG >= 70;
             ($max_pourcent,$nt_max) = ($pourcent_TC,"Y")  if $pourcent_TC >= 70;
        }
        $consensus .= uc($nt_max) if $max_pourcent >= 90  && $nt_max ne "-";
        $consensus .= lc($nt_max) if $max_pourcent < 90  && $max_pourcent >= 70 && $nt_max ne "-";
        $consensus .= "n" if $max_pourcent < 70  || $nt_max eq "-";
    }
    return $consensus;
}
