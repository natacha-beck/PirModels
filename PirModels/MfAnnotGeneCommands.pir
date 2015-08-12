
#
# This class represents a single group of commands.
#
# See also the encapsulating object, <MfAnnotCommandSet>
#

- PerlClass PirObject::MfAnnotGeneCommands
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type            Comments
#---------------------- --------------- --------------- -----------------------
debug                   single          string          any perl true/false
genename                single          string          genename
bashcommands            array           string          commands to run

- EndFieldsTable
- Methods

our $DEBUG = 0; # class global; debug can also be turned on for each object, see above
our $RCS_VERSION='$Id: MfAnnotGeneCommands.pir,v 1.9 2008/12/23 21:42:55 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub Execute {
  my $self          = shift;
  my $cwd           = shift || ""; # cwd of bashcommands
  my $tmpdir        = shift || ""; # where we can create temp files
  my $substitutions = shift || {};  # hash VAR => val to substitute in place of the string %VAR% in bashcommands
  my $keylabel      = shift || "X"; # supplied by MfAnnotGeneCommandSet, used inside temp filenames

  die "Error: no valid CWD supplied for Execute()... got '$cwd'.\n"       unless $cwd && -d $cwd;
  die "Error: no valid TMPDIR supplied for Execute()... got '$tmpdir'.\n" unless $tmpdir && -d $tmpdir;

  my $debug        = $self->get_debug() || $DEBUG;
  my $genename     = $substitutions->{"GENENAME"} || $self->get_genename() || "unk";
  my $bashcommands = $self->get_bashcommands() || [];

  my $bashscript   = join("\n",@$bashcommands) . "\n";

  my %moresubs = %$substitutions; # make copy; we will add some values right now
  $moresubs{"GENENAME"} = $genename        unless exists $moresubs{"GENENAME"};
  $moresubs{"DEBUG"} = ($debug ? "#" : "") unless exists $moresubs{"DEBUG"};

  foreach my $var (keys %moresubs) {
     die "Not a proper variable name '$var'.\n" unless $var =~ m#^[a-zA-Z]+$#;
     my $searchfor = "%" . $var . "%";
     my $val = $moresubs{$var};
     &CheckPath($bashscript,$searchfor,$val) if $bashscript =~ m/$searchfor/ && $var eq "MODPATH";
     $bashscript =~ s/$searchfor/$val/g;
  }

  my $script  = "$tmpdir/bashcom.$genename.$keylabel.MfGC.$$";
  my $outcapt = "$tmpdir/out.$genename.$keylabel.MfGC.$$";
  my $errcapt = "$tmpdir/err.$genename.$keylabel.MfGC.$$";

  my $outscript = new IO::File ">$script"
    or die "Cannot write to file '$script': $!\n";
  print $outscript "#!/bin/bash\n",
           "\n",
           "# This script created automatically by " . __PACKAGE__ . " for gene '$genename' (block '$keylabel').\n",
           "\n",
           $bashscript;
  $outscript->close();

  my $command = "cd '$cwd';/bin/bash '$script' >'$outcapt' 2>'$errcapt'";
  if ($debug) {
    print STDERR "  DEBUG: Executing external script block '$keylabel' for '$genename'.\n",
           "  --- COMMAND : $command\n",
           "  --- SCRIPT $script START ---\n",
           "$bashscript",
           "  --- SCRIPT $script END ---\n";
  }
  system("/bin/bash","-c",$command);

  ($outcapt,$errcapt);
}

sub CheckPath {
  my $bashscript = shift;
  my $searchfor  = shift;
  my $val        = shift;
  
  my @each_string = split(/ /, $bashscript);
  foreach my $string (@each_string){
    next if $string !~ $searchfor;
    $string =~ s/$searchfor/$val/g;
    die "Model file '$string' doesn't exist or isn't readable.\nCheck installation of mfannot_models (see INSTALL.txt)."
      if !(-e $string && -r $string);
  }
}
