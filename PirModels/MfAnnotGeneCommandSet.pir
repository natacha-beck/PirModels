
#
# This class represents the content of a configuration
# file used by mfannot; that file stores a list of external
# programs (with their arguments) that are used to add
# further annotations; the output of the programs are
# expected to be a series of XML documents of type
# AnnotPairCollection.
#

- PerlClass	PirObject::MfAnnotGeneCommandSet
- InheritsFrom	PirObject
- FieldsTable

# Field name		    Sing/Array/Hash	Type	    	Comments
#---------------------- ---------------	---------------	-----------------------
debug                   single          string          any perl true/false
genename		        single		    string	     	genename
percontig               single          string          0 or 1, not yet implemented
filerank                single          int4
commandset              hash            <MfAnnotGeneCommands>  keys = "pre", "post", or 0 .. n

- EndFieldsTable
- Methods

our $DEBUG = 0; # class global; debug can also be turned on for each object, see above
our $RCS_VERSION='$Id: MfAnnotGeneCommandSet.pir,v 1.4 2009/05/08 15:30:59 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub set_debug {
    my $self = shift;
    $self->debug(@_);
}

sub debug {
    my $self = shift;
    return $self->AUTO_debug() unless @_;
    my $commandset = $self->get_commandset();
    foreach my $genecom (values %$commandset) {
        $genecom->set_debug(@_);
    }
    $self->AUTO_debug(@_);
}

sub Execute {
    my $self          = shift;
    my $cwd           = shift || ""; # cwd of bashcommands
    my $tmpdir        = shift || ""; # where we can create temp files
    my $substitutions = shift || {};  # hash VAR => val to substitute in place of the string %VAR% in bashcommands

    die "Error: no valid CWD supplied for Execute()... got '$cwd'.\n"       unless $cwd && -d $cwd;
    die "Error: no valid TMPDIR supplied for Execute()... got '$tmpdir'.\n" unless $tmpdir && -d $tmpdir;

    my $debug        = $self->get_debug() || $DEBUG;
    $self->set_debug($debug); # propagate to each MfAnnotGeneCommands under us
    my $genename     = $self->get_genename() || "unk";

    my $commandset  = $self->get_commandset();
    my @commandkeys = sort { $a <=> $b } grep(/^\d+$/,keys %$commandset);

    my $outfilename  = $substitutions->{"OUTFILE"} || "";
    my $foundoutfile = 0;
    my ($outcapt,$errcapt) = ("(none)","(none)");
    foreach my $commandkey ( "pre", @commandkeys, "post" ) {
        my $genecom = $commandset->{$commandkey} || next; # ignore missing optional blocks
        next if $foundoutfile && $commandkey =~ m#^\d+$#;
        my $commandlabel = $commandkey eq "pre"
                           ? "A-Pre"
                           : $commandkey eq "post"
                           ? "C-Post"
                           : "B-$commandkey";
        ($outcapt,$errcapt) = $genecom->Execute($cwd,$tmpdir,$substitutions,$commandlabel);
        $foundoutfile = 1 if (-f $outfilename && -s _ > 0);
    }
    
    ($outcapt,$errcapt);
}
