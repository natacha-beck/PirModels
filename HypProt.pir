
#
# Contain an hypothetical protein after calculation blast and flip
# And after processing consisting on grouping hsp 
# and ORFs on an entire protein 
#

- PerlClass     PirObject::HypProt
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct  Type                Comments
#---------------------- ------- ------------------- -----------------------
name                    single  string              name of the protein
contigname              single  string              contig wich one the protein belongs
start                   single  int4                gene start
end                     single  int4                gene end
altstart                single  int4                alternative start
starttoodown            single  int4                Indicate if the gene start after all other homologous
starttooup              single  int4                Indicate if the gene start after all other homologous
blaststart              single  int4                start defined by similarity (blast)
exostart                single  int4                start defined by similarity (exonerate)
strand                  single  int4                Strand ORF
exons                   array   <Exon>              Exons of the hypothetical protein
introns                 array   <Intron>            Introns of the hypothetical protein
multicomment            single  string              Comment in order to add in multicomment in AP
startwarning            single  string              These are warnings about the protein for startline
endwarning              single  string              These are warnings about the protein for endline
numorfs                 single  int4                The number of ORF constituing the hypoprotein
thisprot                single  string              The traduction of this hypothetical protein
full5                   single  string              The traduction of this hypothetical protein with 5' tail
protein                 single  string              The protein that has been blasted
evalue                  single  string              The blast evalue for the protein
homologous              array   <Homologous>        Array containing best homologous protein (predicted by Blast)
firstExonerateMatch     single  int4                Position of the first match with Exonerate.
posiffusion             single  int4                Indicate if it's the first or the second gene of the fusion
frameshift              single  int4                A boolean indicate if the gene presented a frameshift
idbyblast               single  int4                1 if annotation is make from blast result
idbyexo                 single  int4                1 if annotation is make from exonerate result
altexons                array   <AnnotPair>         list of AP alternatif exon.
SimiStart               single  int4                Start def by HMM.
AnnotSimi               single  int4                0 or 1.
FirstStart              single  int4                First start find.
namefusiongene          array   string              Info about fusion.
hypfusiongene           single  <HypFusion>         Contain information about an hypothetic gene fusion.
AnnotFusion             single  <AnnotPair>         AP for gene fusion.
NotToAnnot              single  int4                1 if HP is not to annot 2 if HP must be comment else 0.
HPOverlaps              array   string              List of OV HP.
origine                 single  string              Define gene origine can be pt,pt_cyano,mt,mt_alpha.
trimIndex              single  int4                Define the lenght of trimed sequence in HMM align in 5'

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: HypProt.pir,v 1.15 2010/12/20 18:33:57 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

