
#
# AnnotPair : a pair of start/stop lines in a masterfile.
#

- PerlClass	PirObject::AnnotPair
- InheritsFrom	PirObject
- FieldsTable

# Field name            Sing/Array/Hash Type            Comments
#---------------------- --------------- --------------- -----------------------
type                        single      string          Usually G (Gene)
genename                    single      string          Name of gene
startpos                    single      int4            Position of the START line
endpos                      single      int4            Position of the END line
direction                   single      string          "==>" or "<==" or "*==>" or "<==*"
startline                   single      string          Whole START line
endline                     single      string          Whole END line
startmulticomment           array       string          Multiline comment associated with START line
endmulticomment             array       string          Multiline comment associated with END line
startlinenumber             single      int4            Optional line number in masterfile.
endlinenumber               single      int4            Optional line number in masterfile.
introntype                  single      string          Only for introns, type as identified by RNAWeasel
globaltype                  single      string          Only for introns, global type as identified by RNAWeasel when more than 1 intron.


# These fields are used internally by MFannot; they do not correspond to features
# of a masterfile.
splicescore                 single      int4            A score calculate for splice site
phase                       single      int4            Phase of intron 0 if intron split a tri-nt else 1 or 2
score                       single      string          Score or evalue for RNA identified by RNASpinner (evalue) or HMMweasel (score)
lengthofref                 single      int4            The length of homologous gene.
lengthofthis                single      int4            The length of the protein.
firstmissingexon            single      int4            Boolean 1 if the first exon was suspected to be not here else 0.
posiffusion                 single      int4            Indicate if it's the first or the second gene of fusion
namefusiongene              single      string          Name of gene fusioned with.
idbyblast                   single      int4            1 if annotation is make from blast result.
idbyexo                     single      int4            1 if annotation is make from exonerate result.
idbyHMM                     single      int4            1 if annotation is make from HMMweasel result.
idbyRNA                     single      int4            1 if annotation is make from RNAweasel result.
isIntronic                  single      int4            1 if gene is an intronic gene.
RNAcomment                  single      string          comment given by RNAfinder
altexons                    array       <AnnotPair>     list of AP alternatif exon only for G.                
exoscore                    single      int4            raw score defined by exonerate
possStart                   array       string          List of possible start.
isFusioned                  single      int4            0 no fusion, 1 fusion.
origine                     single      string          Define origine of gene pt|pt_cyano|mt|mt_alpha
IdORF                       single      string          A string in order to identified ORF.
HMMlen                      single      int4           || Lenght of HMMmodel.
isDup                       single      int4            Indication for possible duplication
HMMmatch                    single      string          Indicate match of HMMmodel
containStruc                single      int4            1 if contain particular structure (e.g: dpo or rpo) else 0

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: AnnotPair.pir,v 1.17 2011/08/20 20:31:39 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

# Nothing to see here. Move along.

