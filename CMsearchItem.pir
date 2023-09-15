
#
# Represent a CM search result item.
#
# Each Item contain the following fields:
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

- PerlClass PirObject::CMsearchItem
- InheritsFrom PirObject
- FieldsTable

# Field name            Struct          Type            Comments
TargetName              single          string          name of the target sequence (e.g. "test")
TargetAccession         single          string          the target's accession number (e.g. "-")
QueryName               single          string          the name of the query CM (e.g. "new")
QueryAccession          single          string          the query CM's accession number (e.g. "-")
Model                   single          string          the model type ("cm" or "hmm")
ModelFrom               single          int8            the start location of the hit in the model
ModelTo                 single          int8            the end location of the hit in the model
SequenceFrom            single          int8            the start location of the hit in the sequence
SequenceTo              single          int8            the end location of the hit in the sequence
Strand                  single          string          the strand the hit was found on ("+" or "-")
Truncation              single          string          whether the hit is truncated, and where ("no", "5'", "3'", "5'&3'", or "-" for hmm hits)
Pass                    single          int4            which algorithm pass the hit was found on.
GC                      single          string          GC content of the hit
Bias                    single          string          biased composition correction. See the Infernal documentation.
Score                   single          string          bit-score of the hit, including the biased composition correction.
Evalue                  single          string          Expectation value for the hit.
Inc                     single          string          indicates whether or not this hit achieves the inclusion threshold: ’!’ if it does, ’?’ if it does not.
Description             single          string          description of the target sequence (e.g. "-")

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: CMsearchItem.pir,v 1.7 2011/03/31 19:43:47 nbeck Exp $';
our $RCS_FILE='$RCSfile: CMsearchItem.pir,v $';
