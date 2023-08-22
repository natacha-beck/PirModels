
#
# Output from CMsearch
#
#
# Example of CMsearch output:
#
#   # target name         accession query name           accession mdl mdl from   mdl to seq from   seq to strand trunc pass   gc  bias  score   E-value inc description of target
#   # ------------------- --------- -------------------- --------- --- -------- -------- -------- -------- ------ ----- ---- ---- ----- ------ --------- --- ---------------------
#   test                 -         new                  -          cm        1      101      378      264      -    no    1 0.55   0.0   33.0   4.3e-06 !   -
#
#   # Program:         cmsearch
#   # Version:         1.1.1 (July 2014)
#   # Pipeline mode:   SEARCH
#   # Query file:      5S-mito.cm
#   # Target file:     test.fsa
#   # Option settings: cmsearch --tblout out --noali 5S-mito.cm test.fsa
#   # Current dir:     /evora-home/nbeck/cmsearch
#   # Date:            Tue Dec 30 22:29:55 2014
#   # [ok]


- PerlClass PirObject::CMsearchOutput
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type            Comments
CMsearchItems           array           <CMsearchItem>   Array of CMsearchItem objects

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: CMsearchOutput.pir,v 1.7 2011/03/31 19:43:47 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

use Data::Dumper;

# Fill the CMsearchItems array with CMsearchItem objects.
#
# Parse the --tblout output of CMsearch.
# Every single line starting with a # is ignored.
#
# Each result line contains the following fields:
#
#   - target name: name of the target sequence (e.g. "test")
#   - accession: the target's accession number (e.g. "-")
#   - query name: the name of the query CM (e.g. "new")
#   - accession: the query CM's accession number (e.g. "-")
#   - mdl: the model type ("cm" or "hmm")
#   - mdl from: the start location of the hit in the model
#   - mdl to: the end location of the hit in the model
#   - seq from: the start location of the hit in the sequence
#   - seq to: the end location of the hit in the sequence
#   - strand: the strand the hit was found on ("+" or "-")
#   - trunc: whether the hit is truncated, and where ("no", "5'", "3'", "5'&3'", or "-" for hmm hits)
#   - pass: which algorithm pass the hit was found on.
#   - gc: GC content of the hit
#   - bias: biased composition correction. See the Infernal documentation.
#   - score: bit-score of the hit, including the biased composition correction.
#   - E-value: Expectation value for the hit.
#   - inc: indicates whether or not this hit achieves the inclusion threshold: ’!’ if it does, ’?’ if it does not.
#   - description: description of the target sequence (e.g. "-")
#
sub FillCMsearchItems {
    my $self = shift;
    my $tab  = shift;

    my $Items = [];
    foreach my $line(@$tab) {
        if ($line =~ m/^#/) {
            next;
        }
        chomp($line);
        my @fields = split(/\s+/, $line);

        my $Item = new PirObject::CMsearchItem();
        $Item->set_TargetName($fields[0]);
        $Item->set_TargetAccession($fields[1]);
        $Item->set_QueryName($fields[2]);
        $Item->set_QueryAccession($fields[3]);
        $Item->set_Model($fields[4]);
        $Item->set_ModelFrom($fields[5]);
        $Item->set_ModelTo($fields[6]);
        $Item->set_SequenceFrom($fields[7]);
        $Item->set_SequenceTo($fields[8]);
        $Item->set_Strand($fields[9]);
        $Item->set_Truncation($fields[10]);
        $Item->set_Pass($fields[11]);
        $Item->set_GC($fields[12]);
        $Item->set_Bias($fields[13]);
        $Item->set_Score($fields[14]);
        $Item->set_Evalue($fields[15]);
        $Item->set_Inc($fields[16]);
        $Item->set_Description($fields[17]);

        push(@$Items, $Item);
    }
    $self->set_CMsearchItems($Items);
}
