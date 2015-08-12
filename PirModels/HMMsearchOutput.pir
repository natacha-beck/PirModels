
#
# Output from HMMER.
#

- PerlClass PirObject::HMMsearchOutput
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type            Comments
#---------------------- --------------- --------------- -----------------------
Iterations              array           <HMMIteration>     Array of iterations can be used for hmmsearch or jackhmmer

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: HMMsearchOutput.pir,v 1.7 2011/03/31 19:43:47 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub FillFeaturesFromTextOutput {
  my $self     = shift;
  my $tab      = shift;
  
  
  my $resume  = ();
  my @hitinfo = ();
  my %hitinfo = ();
  
  my $isRes  = 0;
  my $isAli  = 0;
  my $isStat = 0;
  
  my $Iteration       = new PirObject::HMMIteration();
  my $Iterations      = [];
  my $Resumes         = [];
  my $HMMalis         = [];
  my $Alignments_a    = [];
  my $ali_lines       = [];
  my $Alignments_h    = {};
  my $BeforeThresh    = 1;
  my $NbResUpperTresh = 0;
  foreach my $line(@$tab) {
    $isRes = 1 if $line =~ /^Scores for complete sequences/o;
    $BeforeThresh = 1 if $line =~ /^Scores for complete sequences/o;
    next if $line =~ /^Scores for complete sequences/o;
    if ($isRes == 1 ) {
      $isRes = 0 if $line =~ /^\s+$/;
      $BeforeThresh = 0 if ($line =~ m/------\s+inclusion\s+threshold\s+------/);
      next if $line =~ m/Sequence\s+Description/ || $line =~ m/^\s*---/ || $line =~ /^\s*$/;
      $line =~ s/^\+//;
      $line =~ s/^\s+//;
      my @info = split(/\s+/,$line);
      my ($f_evalue,$f_score,$f_bias,$b_evalue,$b_score,$b_bias,$exp,$n,$name) 
        = ($info[0],$info[1],$info[2],$info[3],$info[4],$info[5],$info[6],$info[7],$info[8]);
      my $len_info = scalar(@info) - 1;
      my $desc = join( ' ', @info[9..$len_info] );
      # Create Resume
      my $Resume = new PirObject::HMMResume();
      $Resume->set_fEvalue($f_evalue);
      $Resume->set_fScore($f_score);
      $Resume->set_fBias($f_bias);
      $Resume->set_bEvalue($b_evalue);
      $Resume->set_bScore($b_score);
      $Resume->set_bBias($b_bias);
      $Resume->set_exp($exp);
      $Resume->set_NumAli($n);
      $Resume->set_SequenceId($name);
      $Resume->set_SeqIdAndDesc("$name $desc");
      $Resume->set_Description($desc);
      $Resume->set_BeforeThresh($BeforeThresh);
      $NbResUpperTresh++ if $BeforeThresh == 1;
      push(@$Resumes,$Resume);
      push @hitinfo, [ $name, $desc, $f_evalue, $f_score ];
      $hitinfo{$name} = $#hitinfo;
    }
        
    $isAli = 1 if $line =~ m/^Domain\s+annotation\s+for/;
    next if $line =~ m/^Domain\s+annotation\s+for/;
    if ($isAli) {
      $isAli = 0 if $line =~ m/^Internal\s+pipeline\s+statistics\s+summary/;
      next if $line =~ m/acc$/ || $line =~ m/^\s*---/;
      push(@$ali_lines,$line);
      
      if ($line =~ m/^>>/) {
        $line =~ s/^>>\s+//;
        my @info = split(/\s+/, $line);
        my $ali_name = $info[0];
        my $len_info = scalar(@info) - 1;
        my $ali_desc = join( ' ', @info[1..$len_info]);
        next;
      }
      if ($line =~ m/\s+\d+\s+[!|?]/) {
        $line =~ s/^\s+//;
        my @info = split(/\s+/,$line);
        my ($d_num,$d_indic,$d_score,$d_bias,$d_cvalue,$d_ivalue,$d_hmmfrom,$d_hmmto,
          $d_hmmbra,$d_alifrom,$d_alito,$d_alibra,$d_envfrom,$d_envto,$d_envbra,$d_acc) = @info;
        
        my $HMMAli = new PirObject::HMMAli();
      }
    }
    
    $isStat = 1 if ($line =~ m/^Internal\s+pipeline\s+statistics\s+summary/);
    next if ($line =~ m/^Internal\s+pipeline\s+statistics\s+summary/);
    if ($isStat == 1) {
      next if $line =~ m/^\s*---/;
      if ($line =~ m/^Query\s+model\(s\):\s+(.+)/) {
        $Iteration->set_QueryModel($1);
        $Iteration->set_ModelSize($1) if $Iteration->get_QueryModel() =~ m/\(\s*(\d+).+\)/;
      }
      $Iteration->set_TargetSequences($1) if $line =~ m/^Target\s+sequences:\s+(.+)/;
      $Iteration->set_MSVFilter($1)       if $line =~ m/^Passed\s+MSV\s+filter:\s+(.+)/;
      $Iteration->set_BiasFilter($1)      if $line =~ m/^Passed\s+bias\s+filter:\s+(.+)/;
      $Iteration->set_VitFilter($1)       if $line =~ m/^Passed\s+Vit\+filter:\s+(.+)/;
      $Iteration->set_FwdFilter($1)       if $line =~ m/^Passed\s+Fwd\+filter:\s+(.+)/;
      $Iteration->set_SearchSpace($1)     if $line =~ m/^Initial\s+search\s+space\s+\(Z\):\s+(.+)/;
      $Iteration->set_domZ($1)            if $line =~ m/^Domain\s+search\s+space\s+\(domZ\):\s+(.+)/;
      $Iteration->set_CPUTime($1)         if $line =~ m/^\#\s+CPU\s+time:\s+(.+)/;
      $Iteration->set_McSec($1)           if $line =~ m/^\#\s+Mc\/sec:\s+(.+)/;
      $Iteration->set_NbResUpperTresh($NbResUpperTresh);
      if ($line =~ m/^\#\s+Mc\/sec:\s+(.+)/){
        my $all_alignments = &TreatAlignment($ali_lines);
        &AddAliToResume($all_alignments,$Resumes);
        $Iteration->set_resume($Resumes);            
        $Resumes = [];
        $ali_lines = [];
        push(@$Iterations,$Iteration);
        $Iteration = new PirObject::HMMIteration();
      }
      $Iteration->set_IncludedMSA($1)     if $line =~ m/^\@\@\s+New\s+targets\s+included:\s+(.+)/;
    }
  }
  $self->set_Iterations($Iterations);
}

sub TreatAlignment {
  my $lines = shift;
  
  my ($name,$desc,$num_dom) = ("","","");
  my $all_alignments = {};
  my $alignments   = {};
  foreach my $line (@$lines){
        
    next if $line  =~ m/^\s$/ || $line =~ m/\s+Alignments\s+for/;
    last if ($line =~ m/^\s+\[No\s+targets\s+detected\s+that\s+satisfy/);
    if ($line =~ s/^>>\s+// || $line =~ m/^Internal\s+pipeline\s+statistics/) {
      if ($name ne "") {
        $all_alignments->{"$name $desc"} = $alignments;
        $alignments = {};
      }
      my @info = split(/\s+/, $line);
      $name = $info[0];
      my $len_info = scalar(@info) - 1;
      $desc = join( ' ', @info[1..$len_info]);
     }
     elsif ($line =~ m/^\s+\[No\s+individual\s+domains\s+that\s+satisfy/) {
       my $HMMAli = new PirObject::HMMAli();
     }
     elsif ($line =~ m/\s+\d+\s+([!|?])/) {
       $line =~ s/^\s+//;
       my @info = split(/\s+/,$line);
       my ($d_num,$d_indic,$d_score,$d_bias,$d_cvalue,$d_ivalue,$d_hmmfrom,$d_hmmto,
         $d_hmmbra,$d_alifrom,$d_alito,$d_alibra,$d_envfrom,$d_envto,$d_envbra,$d_acc) = @info;
       my $HMMAli = new PirObject::HMMAli();
       $HMMAli->set_id($d_num);
       $HMMAli->set_score($d_score);
       $HMMAli->set_bias($d_bias);
       $HMMAli->set_Cvalue($d_cvalue);
       $HMMAli->set_Ivalue($d_ivalue);
       $HMMAli->set_hmmFrom($d_hmmfrom);
       $HMMAli->set_hmmTo($d_hmmto);
       $HMMAli->set_hmmBracket($d_hmmbra);
       $HMMAli->set_aliFrom($d_alifrom);
       $HMMAli->set_aliTo($d_alito);
       $HMMAli->set_aliBracket($d_alibra);
       $HMMAli->set_envFrom($d_envfrom);
       $HMMAli->set_envTo($d_envto);
       $HMMAli->set_envBracket($d_envbra);
       $HMMAli->set_acc($d_acc);
       $alignments->{$d_num} = $HMMAli;
     }
     elsif ($line =~ m/^\s+==\s+domain\s+(\d+)/) {
       $num_dom = $1;
     }
     else {
      $line =~ s/\n$//;
      my $HMMAli = $alignments->{$num_dom};
      my $ali    = $HMMAli->get_ali() || [];
      $line =~ s/^\s+//;
      push(@$ali,$line);
      $HMMAli->set_ali($ali);
     }
   }
   return $all_alignments;
}

sub AddAliToResume {
  my ($all_alignments,$Resumes) = @_;
  
  print "Warning: Number of resume != Number of alignments\n" if (scalar(@$Resumes)) != scalar (keys %$all_alignments);
  foreach my $Resume (@$Resumes) {
    my $SeqIdAndDesc =  $Resume->get_SeqIdAndDesc();
    my $ali          =  $all_alignments->{$SeqIdAndDesc};
    $Resume->set_alignments($ali);
  }
}
