
#
# A module for processing options
#

- PerlClass PirObject::Option
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct   Type               Comments
#---------------------- ------- ------------------- -----------------------
outputfile              single  string              A new outputfile for the masterfile (option -o)
pepdirectory            single  string              A peptide directory for the closest organism
genetic                 single  int4                A number representing the genetic code used (option -g)
debug                   single  int4                A boolean displaying step by step, the programme process (-d option)
logfile                 single  string              A string containig the logfile (-l option)
islogfile               single  int4                A boolean saying if yes or not there is a logfile 
flip2                   single  int4                Parameter for flip in annotation (-3 option)
blast2                  single  int4                Parameter for blast in annotation (-4 option)
help                    single  int4                A boolean for displaying some help (-h option)
masterfile              single  string              The masterfile name. (default option)
minlenemptyorf          single  int4                Minimum length for keeping empty ORF (non corresponding ORF)
overlappingcutoff       single  int4                A value between 0 and 100 allowing overlapping
orfOVorf                single  int4                A value in amino acid
orfOVgene               single  int4                A value in amino acid
orf                     single  int4                A boolean telling if Orf have to be shown in the Masterfile
matrix                  single  string              The matrix used to run blast
minexonsize             single  int4                The minimum exon size. Used in the alignement. 
minintronsize           single  int4                The minimum intron size
maxintronsize           single  int4                Maximum intron size
ext_config              single  string              File of configuration for different annotation (rnpB, rnl, rns)
ext_select              single  string              List of genes to annotate with external programs (-e option)
partial                 single  int4                This will cause mfannot to only run a subset of all its built-in analysis
insertion               single  int4                Minimum length used in order to report insertion.
lvlintron               single  int4                Indicate level of intron identification (1 or 2).
motfile                 single  string              File of configuration for research of motifs.
lvlmot                  single  int4                Indicate level of motif identification.
tmpdir                  single  string              Define the temporary work directory.
light                   single  int4                Don't run HMMer for all not found gene and don't seartch endonuclease
sqnformat               single  int4                If set perform mf -> sqn conversion 
tblformat               single  int4                If set create the tbl output
prm                     single  int4                Define if prot.prm file must be used or not.

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Option.pir,v 2.20 2011/04/09 22:37:26 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub ExitWithUsage {
  print &Usage, "\n";
  exit 0;
}

sub Usage { 

my $USAGE = <<USAGE_TEXT;

This is mfannot version $main::VERSION by N. Beck, P. Rioux, D. To and T. Hoellinger.

Usage: mfannot [options] masterfile

Mfannot removes all annotations present in the masterfile.

Available options :

    --blast   Blast e-value cutoff
              This option allows the user to set the minimum signifiant e-value
              for ORF threshold.
              Default: 1e-10
    
    -d, --debug
              Use debugging mode. Print debugging information
              

    --el, --emptyorflen  empty ORF minimum length     
              This option allows the users to supply the cutoff value for an
              ORF (in nuceotide) they must be multiple of 3, which is found
              not to correspond to a gene.
              It will instead appear in the Masterfile as ncorf (non
              corresponding ORF).
              Default: 300nt

    --ext_config 
             A file used in order to call external programs. 
             Use for annotation of different genes like rnpB, rns and rnl.
             Default: look in your current directory, after in your home after 
             in global variable MFANNOT_EXT_CFG_PATH for '.mfannot_external_programs.conf'.
     
    --ext_select
             A list of names used to select or unselect which external programs
             to run (as specified in the --ext_config option above).
             The different names should be separated by a comma as in 'rnpB,rns',
             in this case ONLY the external programs needed to annotate 'rnpB' and
             'rns' will be executed. If you want unselect an external programs you
             must add no before the name of external programs : 'nornpB'; in this
             case all programs run except those specified with a 'no' prefix.
             Specifying a mixed set of 'no' and non-'no' programs has the same
             effect as specifying only the programs with 'no'.
    
    -g, --genetic       genetic code
              Genetic code used.
              ---------------------------------
              1 =>  Standard (default)
              2 =>  Vertebrate Mitochondrial                  AGA=Ter(*),AGG=Ter(*),AUA=Met(M),UGA=Trp(W)
              3 =>  Yeast Mitochondrial                       ATA=Met(M),CTN=Thr(T),TGA=Trp(W)
              4 =>  Mold Mitochondrial                        TGA=Trp(W)
              5 =>  Invertebrate Mitochondrial                AGA=Ser(S),AGG=Ser(S),ATA=Met(M),TGA=Trp(W)
              6 =>  Ciliate Dasycladacean Hexamita Nuclear    TAA=Gln(Q),TAG=Gln(Q)
              9 =>  Echinoderm Flatworm Mitochondrial         AAA=Asn(N),AGA=Ser(S),AGG=Ser(S),TGA=Trp(W)
              10 => Euplotid Nuclear                          TGA=Cys(C)
              11 => Bacterial and Plant Plastid               
              12 => Alternative Yeast Nuclear                 CTG=Ser(S)
              13 => Ascidian Mitochondrial                    AGA=Gly(G),AGG=Gly(G),ATA=Met(M),TGA=Trp(W)
              14 => Alternative Flatworm Mitochondrial        AAA=Asn(N),AGA=Ser(S),AGG=Ser(S),TAA=Tyr(Y),TGA=Trp(W)
              15 => Blepharisma Macronuclear                  TAG=Gln(Q)
              16 => Chlorophycean Mitochondrial               TAG=Leu(L)
              21 => Trematode Mitochondrial                   TGA=Trp(W),ATA=Met(M),AGA=Ser(S),AGG=Ser(S)
              22 => Scenedesmus Obliquus Mitochondrial        TCA=Stop(*),TAG=Leu(L)
              23 => Thraustochytrium Mitochondrial            TTA=Stop(*)
              ---------------------------------
    
    -h, --help
              Display a help and usage, with syntax and options of the
              programme.
              
    -i, --insertion
              This option allows the user to change the length of insertion in order 
              to report them.

    -l, --logfile logfile
              This option allows the user to log the state of mfannot into a user
              chosen file.
    
    --light   Don't perfrom endonuclease search, and don't search for all gene by HMM.
              It's a boolean value just set or not. Default: false  
  
    --matrix  This allows the user to choose which alignment matrix is used
              during the blast. 

              Available matrix is this usually used by BLAST:
              BLOSUM45, BLOSUM62 (default), BLOSUM 80.
              PAM30, PAM70.

    --maxis, --maxintronsize   Maximum intron size
              This option allows the user to modify the default maximum intron
              size (in nucleotides). During annotation, ORFs are grouped
              together to form a hypothetical protein. When this size is bigger,
              the gap can not be considered as an intron and the multiple ORFs
              form multiple hypothetical proteins.
              Default: 3000

    --mines, --minexonsize   Minimum exon size
              This option allows the user to modify the default minimum exon
              size (in nucleotides) that mfannot uses during internal structure
              prediction. This value should be an integer. 
              Default: 3
    
    --minis, --minintronsize   Minimum intron size
              This option allows the user to modify the default minimum intron
              size (in nucleotides) that mfannot uses during internal structure
              prediction. This value should be an integer.
              Default: 142

    --minorflen   minumum ORF length
              This option allows the user to choose the size of the minumum ORFs
              (in amino acids) that are produced using Flip. This value must be
              an integer.
              Default: 40
    
    -o, --outputfile  outputfile
              This is name of the new masterfile to be created. The default
              output file will use the append '.new' to the end of the input
              file name. Should this file already exist, an integer will be
              appended to the end of the file, incremented by 1 from the
              largest number appended to existing file.
              
    --oc, --overlapcut  Overlapping cutoff
              This value is a cutoff that represents the permitted overlapping
              proportion of a non-corresponding ORF that overlaps a predicted
              gene in nucleotide or on other non-corresponding ORF, value in 
              percent.
              Default : 30
              
    --orfOVorf, 
              Special case, 2 orfs is overlapping but both of them make under 
              Xaa of length, annotate the 2 ORFs
              Default : 300aa
              
    --orfOVgene, 
              Special case, 1 orf is overlapping a gene and make Xaa of length
              annotate this one.
              Default : 200aa
    
    -prm,
              If used try to used prot.prm file present in current directory.
    
    -p, --pepdirectory
              Path to the peptide directory containing peptide files. By
              default mfannot uses a collection of default peptide libraries.
              Peptide files must contain the suffix '.pep'.
              
    --partial
              Must be used when the genome his known to be partial or incomplete;
              this will cause mfannot to only run a subset of all its built-in analysis.'
              
    --sqn     Produce a sqn format file. Default: false.  

    --tbl     Generate a tbl file. Default: false.

    --T       Define the temporary work directory.
              
    --lvlintron
              If is 1 : run RNASpinner in all intragenic introns and check for rnl
              and rns introns.
              Default 2 : run RNASpinner on whole genome.
    
    --motfile
             A file used for motifs identification. 
             Default: look in your current directory, after in your home after 
             in global variable MFANNOT_EXT_CFG_PATH for '.motsearch.pat'.
             See in '/share/supported/mfannot/config/.motsearch.pat'.
    
    --lvlmot
              Default 0 : run mfannot without motifs identification.
              If is 1   : run only motifs identification.
              If is 2   : run mfannot with motifs identification'.

USAGE_TEXT

     return $USAGE;
}

sub FillOption {
    use Getopt::Long;                                      #  Options treatment
    use File::Spec;
    use Cwd;
   
   # Define path, for remove hardcoding path.
   # 1. For blast library.
   my @LIB_PATH = (($ENV{"HOME"} || ".")); # You can add other search directories here
   push(@LIB_PATH,split(/:/,$ENV{"MFANNOT_LIB_PATH"})) if $ENV{"MFANNOT_LIB_PATH"};

   #Check for directory
   my $DIR_LIB    = "";
   foreach my $dir (@LIB_PATH) {
       next if !( -d "$dir/identified" );
       $DIR_LIB    = "$dir/identified";
       last;
   }
   die "No directory was found for blast\n"
        if !$DIR_LIB;
   
   # 2. For external config file.
   my @CFG_PATH      = (
   ".",
   # You can add other search directories here
   ($ENV{"HOME"} || "."),
   );
   push(@CFG_PATH,split(/:/,$ENV{"MFANNOT_EXT_CFG_PATH"}))
       if $ENV{"MFANNOT_EXT_CFG_PATH"};
   
   
   #Check for config file for external programs
   my $DIR_CFG    = "";
   foreach my $dir (@CFG_PATH) {
       next if !( -e "$dir/.mfannot_external_programs.conf" );
       $DIR_CFG    = $dir;
       last;
   }
   die "The config file '.mfannot_external_programs.conf' doesn't find. Check your installation for this one.\n"
       if !$DIR_CFG;

   my $CONFIGFILE      = "$DIR_CFG/.mfannot_external_programs.conf";
   
   # 2. For external config file.
   my @MOT_PATH      = (
   ".",
   # You can add other search directories here
   ($ENV{"HOME"} || "."),
   );
   push(@MOT_PATH,split(/:/,$ENV{"MFANNOT_EXT_CFG_PATH"}))
       if $ENV{"MFANNOT_EXT_CFG_PATH"};
   
   
   #Check for config file for external programs
   my $DIR_MOT    = "";
   foreach my $dir (@MOT_PATH) {
       next if !( -e "$dir/.motsearch.pat" );
       $DIR_MOT    = $dir;
       last;
   }
   die "The config file '.motsearch.pat' doesn't find. Check your installation for this one.\n"
       if !$DIR_MOT;

   my $MOTFILE      = "$DIR_MOT/.motsearch.pat";
         
   my $self = shift;         # get the object
   
   ########## FIRST TIME : FILL TABLE WITH DEFAULT OPTION
   $self->set_outputfile ("");
   $self->set_pepdirectory ($DIR_LIB);
   $self->set_genetic (1);
   $self->set_insertion (10);
   $self->set_logfile (""); 
   $self->set_flip2 (40);
   $self->set_blast2 ("1e-10");       
   $self->set_debug (0);
   $self->set_prm(0);
   $self->set_minlenemptyorf (300);  # in nt
   $self->set_overlappingcutoff  (30);
   $self->set_orfOVorf  (300);
   $self->set_orfOVgene (200);
   $self->set_orf (1);
   $self->set_matrix ("BLOSUM62");         
   $self->set_maxintronsize (4000);
   $self->set_minintronsize (142);
   $self->set_minexonsize (3);  
   $self->set_ext_config ($CONFIGFILE);
   $self->set_ext_select("nointronI,nointronII");
   $self->set_lvlintron(2);
   $self->set_partial(0);
   $self->set_motfile($MOTFILE);
   $self->set_lvlmot(0);
   
    ######  THEN FILL WITH LINE COMMAND OPTION ############
   
   my %opts;                                                              #  Hash array for storing options
   my %optioncommand = ( "help"             => \&ExitWithUsage,           # Exit the function with the usage
                         "h"                => \&ExitWithUsage,          
                         "outputfile:s"     => \$opts{'o'},               # Give an inputfile
                         "o:s"              => \$opts{'o'},
                         "pepdirectory:s@"  => \$opts{'p'},               # Give a pepdirectory
                         "p:s@"             => \$opts{'p'},   
                         "genetic:i"        => \$opts{'g'},               # Give a genetic code
                         "g:i"              => \$opts{'g'},
                         "insertion:f"      => \$opts{'insertion'},       # The minimum insetion size for report
                         "i:f"              => \$opts{'insertion'},
                         "logfile:s"        => \$opts{'l'},               # Give a logfile 
                         "l:s"              => \$opts{'l'},            
                         "blast:f"          => \$opts{'blast2'},
                         "minorflen:f"      => \$opts{'flip2'},
                         "debug"            => \$opts{'d'},               # Debug Mode
                         "prm"              => \$opts{'prm'},             # use or not prm file
                         "d"                => \$opts{'d'},
                         "emptyorflen:i"    => \$opts{'minlenemptyorf'},  # The minimum empty length for an ORF
                         "el:i"             => \$opts{'minlenemptyorf'},  # The minimum empty length for an ORF 
                         "overlapcut:f"     => \$opts{'overlapcut'},      # A value between 0 and 100 : overlapping percent cutoff
                         "oc:f"             => \$opts{'overlapcut'},      # A value between 0 and 100 : overlapping percent cutoff
                         "orfOVorf:f"       => \$opts{'orfOVorf'},        # Length in amino acid 
                         "orfOVgene:f"      => \$opts{'orfOVgene'},       # Length in amino acid
                         "norf"             => \$opts{'norf'},            # A value for non showing orfs
                         "matrix:s"         => \$opts{'matrix'},          # permit the display of all Orf
                         "maxintronsize:f"  => \$opts{'maxintronsize'},   # The maximum intron size allowed
                         "maxis:f"          => \$opts{'maxintronsize'},   # The maximum intron size allowed     
                         "minintronsize:f"  => \$opts{'minintronsize'},   # The minimum intron size allowed
                         "minis:f"          => \$opts{'minintronsize'},   # The minimum intron size allowed      
                         "minexonsize:f"    => \$opts{'minexonsize'},     # The minimum exon size allowed
                         "mines:f"          => \$opts{'minexonsize'},     # The minimum exon size allowed
                         "ext_config:s"     => \$opts{'ext_config'},      # The Path of ext_config
                         "ext_select:s"     => \$opts{'ext_select'},      # The list of genes
                         "lvlintron:i"      => \$opts{'lvlintron'},       # 1 or 2 indicate lvl of introns identification
                         "partial"          => \$opts{'partial'},         # This will cause mfannot to only run a subset of all its built-in analysis
                         "light"            => \$opts{'light'},           # light version don't search for endo and for all gene
                         "sqnformat"        => \$opts{'sqn'},             # Convert mf -> sqn
                         "tblformat"        => \$opts{'tbl'},             # Create a tbl file
                         "T:s"              => \$opts{'T'},               # tmp dir
                         "motfile:s"        => \$opts{'motfile'},         # The path of .motsearch.pat
                         "lvlmot:i"         => \$opts{'lvlmot'}           # 0,1 or 2 indicate lvl of motifs identification
                       );
   GetOptions (%optioncommand);                                           # Execute the command and fill %opts
   
   ######## PROCESS PARSE LINE COMMAND   ##################
  
   ######## treat case per case each option
       
   ####General options
   $self->set_outputfile ($opts{'o'}) if defined($opts{'o'}) ;
    
   if (defined $opts{'g'}) {
       if ($opts{'g'} == 0) {    # if the option is not given
           print "Genetic id not given\n";
       }
       else {
           $self->set_genetic ($opts{'g'}) 
       }
   }
   
   if (defined($opts{'insertion'})) {
       if ($opts{'insertion'} <= 0) { # if the option is not given
           print "Insertion size Size not given/allowed in command line\n";
       }
       else {
           $self->set_insertion ($opts{'insertion'});
       }
   }
   
   if (defined $opts{'l'}) {
       if ($opts {'l'} eq "") {    # if the option is not given
           print "Logfile not given\n";
       }
       else {
           $self->set_logfile ($opts {'l'});
       }
   }
   
    if (defined $opts{'ext_config'}) {
       if ($opts{'ext_config'} eq "") {    # if the option is not given
           print "Config file for external commands not given\n";
       }
       else {
           $self->set_ext_config ($opts{'ext_config'})
       }
    }
    
    if (defined $opts{'ext_select'}) {
       if ($opts{'ext_select'} eq "") {    # if the option is not given
           print "List of selected programs for external commands not given\n";
       }
       else {
           $self->set_ext_select ($opts{'ext_select'}) 
       }
   }
   
   if (defined $opts{'lvlintron'}) {
       $self->set_lvlintron ($opts{'lvlintron'});
   }
   
   ####parameters
   if (defined($opts{'flip2'})) {
       if ($opts{'flip2'} <= 0) { # if the option is not given
           print "ORF minimum len size (minorflen) not given/allowed in command line\n";
       }
       else {
           $self->set_flip2 ($opts{'flip2'});
       }
   }
   if (defined($opts{'blast2'})) {
       if ($opts{'blast2'} <= 0) { # if the option is not given
           print "Blast evalue cutoff not given/allowed in command line\n";
       }
       else {
           $self->set_blast2 ($opts{'blast2'});
       }
   }
   if (defined($opts{'minlenemptyorf'})) {
       if ($opts{'minlenemptyorf'} <= 0) { # if the option is not given
           print "Minimum empty ORF len not given/allowed in command line\n";
       }
       else {
           $self->set_minlenemptyorf ($opts{'minlenemptyorf'});
       }
   }
   
   $self->set_overlappingcutoff ($opts {'overlapcut'}) if defined($opts{'overlapcut'}) ; # 0 is allowed
   $self->set_orfOVorf  ($opts {'orfOVorf'})  if defined($opts{'orfOVorf'}) ; # 0 is allowed
   $self->set_orfOVgene ($opts {'orfOVgene'}) if defined($opts{'orfOVgene'}) ; # 0 is allowed
   
   if (defined($opts{'matrix'})) {
       if ($opts{'matrix'} eq "") { # if the option is not given
           print "matrix not given in command line\n";
       }
       else {
           $self->set_matrix ($opts{'matrix'});
       }
   }
   
   if (defined($opts{'maxintronsize'})) {
       if ($opts{'maxintronsize'} <= 0) { # if the option is not given
           print "Max Intron Size not given/allowed in command line\n";
       }
       else {
           $self->set_maxintronsize ($opts{'maxintronsize'});
       }
   }
   
   if (defined($opts{'minintronsize'})) {
       if ($opts{'minintronsize'} <= 0) { # if the option is not given
           print "Min Intron Size not given/allowed in command line\n";
       }
       else {
           $self->set_minintronsize ($opts{'minintronsize'});
       }
   }
   
   if (defined($opts{'minexonsize'})) {
       if ($opts{'minexonsize'} <= 0) { # if the option is not given
           print "Min Exon Size not given/allowed in command line\n";
       }
       else {
           $self->set_minexonsize ($opts{'minexonsize'});
       }
   }
   
   $self->set_light (1)   if defined ($opts{'light'});
   $self->set_sqnformat (1) if defined ($opts{'sqn'});  
   $self->set_tblformat (1) if defined ($opts{'tbl'});

 
   if (defined $opts{'T'}) {
       if ($opts{'T'} eq "") {    # if the option is not given
           print "TMP dir not given\n";
       }
       else {
           $self->set_tmpdir ($opts{'T'}) 
       }
   }
   
   if (defined $opts{'motfile'}) {
       if ($opts{'motfile'} eq "") {    # if the option is not given
           print "Config file for motifs research not given\n";
       }
       else {
           $self->set_motfile($opts{'motfile'}) 
       }
   }
   
   if (defined $opts{'lvlmot'}) {
       $self->set_lvlmot($opts{'lvlmot'});
   }
   
   ###searching for others
   my %isdefinedoptions;                                       #   Array saying if yes or not boolean are defined
   $self->set_debug (1)   if defined ($opts{'d'});
   if (defined ($opts{'prm'})){
       my $initial_dir   = getcwd;
       my $protprmFile   = "$initial_dir/prot.prm";
       if (!(-f $protprmFile)) {
           print "WARNING: No prot.prm file found in current directory\n";
       }
       else {
           $self->set_prm(1);
       }
   }
   $self->set_partial (1) if defined ($opts {'partial'});
   $self->set_orf (0)     if defined ($opts{'norf'}) ;
   
   ### searching for masterfile ###
   my $masterfile = shift (@ARGV) || "";
   $self->set_masterfile ($masterfile);                        #   Look for the masterfile                    
        
   #########  FOUR PROCESS #############
   # Masterfile name processing
   if (($self->masterfile eq "")  or   (not -r $self->masterfile)) {
       print "No masterfile found\n";
       &ExitWithUsage
   }
   
   ### other options process         
   # Log file processing, an other option just telling you if a logfile name is defined
   $self->logfile ne "" ? $self->set_islogfile (1) : $self->set_islogfile (0);
   # Outputfile option process
   my ($volume,$directories,$file_name) = File::Spec->splitpath($self->masterfile);
   my $current_dir = getcwd;
   my $outfile = "$current_dir/$file_name";
   $self->set_outputfile("$outfile.new") if ($self->outputfile eq "");
}
