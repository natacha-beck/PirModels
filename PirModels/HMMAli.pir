
#
# Parser for HMM result.
#

- PerlClass PirObject::HMMAli
- InheritsFrom  PirObject
- FieldsTable

# Field name            Sing/Array/Hash Type            Comments
#---------------------- --------------- --------------- -----------------------
id                      single          int4            identification number
score                   single          int4            score
bias                    single          int4            bias
Cvalue                  single          int4            c-value
Ivalue                  single          int4            i-value
hmmFrom                 single          int4            start of hmm ali
hmmTo                   single          int4            end of hmm ali
hmmBracket              single          string          representation of hmm ali with bracket
aliFrom                 single          int4            start of ali 
aliTo                   single          int4            end of ali 
aliBracket              single          string          representation of ali with bracket
envFrom                 single          int4            start env
envTo                   single          int4            end env
envBracket              single          string          representation of env with bracket
acc                     single          int4
pos                     single          int4            3 values, 5 if is 5', 3 if is 3' other 4
ali                     array           string          contain alignment.
SeqIdAndDesc            single          string          sequence identifier and description

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: HMMAli.pir,v 1.4 2012/01/21 20:48:19 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

