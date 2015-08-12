
#
# Collection of AnnotPair objects; usually created from
# a PotentialResult object
#

- PerlClass PirObject::AnnotPairCollection
- InheritsFrom  PirObject
- FieldsTable

# Field name            Sing/Array/Hash Type            Comments
#---------------------- --------------- --------------- -----------------------
genename                single          string
contigname              single          string
annotpairlist           array           <AnnotPair>

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: AnnotPairCollection.pir,v 1.11 2009/05/08 15:30:59 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub MakeFromPotentialResult {
    my $self     = shift;
    my $genename = shift or die "Need a gene name for MakeFromPotentialResult().\n";
    my $res      = shift or die "Need a PotentialResult object for MakeFromPotentialResult().\n";
    my $comment_elements = shift || 0;  # Optional: create 'comment' annotpairs for MATCH elements
    my $idByHMM  = shift || 0;

    my $class = ref($self) || $self;

    $self = $class->new() if $self eq $class;

    my $elemlist  = $res->get_elementlist();
    my $contig    = $res->get_sequenceName();
    my $score     = $res->get_combinedscore();
    
    # Split elements by piece number
    my %piece2elemlist = ();
    foreach my $elem (@$elemlist) {
        my $piece = $elem->get_piecenumber();
        $piece = -1 if !defined($piece); # zero is a legal piece number too.
        my $sublist = $piece2elemlist{$piece} ||= [];
        push(@$sublist,$elem);
    }

    my $many_pieces = (scalar(keys %piece2elemlist) > 1);
    my $suffixletter = "a"; # used only when many pieces

    my $annotpairlist = [];

    foreach my $piece (sort { $a <=> $b } keys %piece2elemlist) {
        my $sublist = $piece2elemlist{$piece};
        shift(@$sublist) while @$sublist && $sublist->[0]->get_elemType()  ne "MATCH";
        pop(@$sublist)   while @$sublist && $sublist->[-1]->get_elemType() ne "MATCH";
        my $suffix = $many_pieces ? "_$suffixletter" : "";
        $suffixletter++; # magical: a, b, c, d, etc
        my $start = $sublist->[0]->get_seqStart();
        my $stop  = $sublist->[-1]->get_seqStop();
        my $annotpair = new PirObject::AnnotPair(
            type     => "G",
            genename => "$genename$suffix",
            startpos => $start+1,
            endpos   => $stop+1,
            score    => $score,
            idbyHMM  => $idByHMM
        );
        push(@$annotpairlist,$annotpair);

        if ($comment_elements) {
            # $arbitrary_line_number is used simply to position comments
            # relative to one another, the exact value is not important.
            # We start at 1000000 which is large enough so that +1 or -1
            # operations leave it positive, but put these new comments
            # BELOW any other legitimate annotations at the same positions
            my $arbitrary_line_number = 1000000;
            foreach my $elem (@$sublist) {
                my $type  = $elem->get_elemType();
                next unless $type eq "MATCH";
                my $id    = $elem->get_elementId() || "UnknownId";
                $id =~ s/\.Q$//;
                my $start = $elem->get_seqStart();
                my $stop  = $elem->get_seqStop();
                my $arrow = $start <= $stop ? "==>" : "<==";
                my $comment = new PirObject::AnnotPair(
                    type      => "G",  # not a real GENE
                    startpos  => $start+1,
                    endpos    => $stop+1,
                    genename  => "$genename$suffix-$id",
                    startline => ";; HMMWeasel element '$id' of '$genename' $arrow start",
                    endline   => ";; HMMWeasel element '$id' of '$genename' $arrow end",
                );
                $comment->set_startlinenumber($arbitrary_line_number);
                $arbitrary_line_number += ($arrow eq "<==" ? -1 : 1);
                $comment->set_endlinenumber($arbitrary_line_number);
                $arbitrary_line_number += ($arrow eq "<==" ? -1 : 1);
                push(@$annotpairlist,$comment);
            }
        }
    }
 
    $self->SetMultipleFields(
        genename      => $genename,
        contigname    => $contig,
        annotpairlist => $annotpairlist,
    );

    $self;
}
