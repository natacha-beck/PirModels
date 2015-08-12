
#
# This class represents the content of a configuration
# file used by mfannot; that file stores a list of external
# programs (with their arguments) that are used to add
# further annotations; the output of the programs are
# expected to be a series of XML documents of type
# AnnotPairCollection.
#

- PerlClass	PirObject::MfAnnotExternalProgs
- InheritsFrom	PirObject
- FieldsTable

# Field name		    Sing/Array/Hash	Type		              Comments
#---------------------- ---------------	------------------------- -----------------------
filename		        single	    	string		              optional
geneprogs	        	hash		    <MfAnnotGeneCommandSet>   # genename => what to run

- EndFieldsTable
- Methods

our $RCS_VERSION='$Id: MfAnnotExternalProgs.pir,v 1.7 2009/05/08 15:30:59 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

# Sample format of text file
#
# # comment
# GeneName=rnl
# PerContig=true        # optional line; not yet implemented
# PreCommands           # optional block
#   blah blah blah line 1
#   blah blah blah line 2
# EndCommands
# Commands                 # one or many such blocks
#   blah blah blah line 1
#   blah blah blah line 2
# EndCommands
# Postcommands          # optional block
#   blah blah blah line 1
#   blah blah blah line 2
# EndCommands

sub ImportFromTextFile {
    my $self = shift;
    my $filename = shift;

    my $class = ref($self) || $self;

    $self = $class->new() if $self eq $class;
    $self->set_filename($filename);

    my $fh = new IO::File "<$filename"
        or die "Cannot read from file '$filename': $!\n";
    my @file = <$fh>;
    $fh->close();

    my $genecoms = {};
    my $filerank = 0;
    while (@file) {
        my $line = shift(@file);
        next if $line =~ m/^\s*$|^\s*#/;

        # Expects "genename"
        if ($line !~ m/^\s*genenames?\s*=\s*(\w+(\s*,\s*\w+)*)\s*$/i) {
            die "Error: unparsable line in '$filename' (expected \"genename=\"), got:\n$line";
        }
        my $genename = $1;  # potentially a list, like "abc,def"
        $genename =~ s/\s+//;
        die "Error: genename '$genename' seen more than once in file '$filename'.\n"
            if exists $genecoms->{$genename};
        
        my $genecom = new PirObject::MfAnnotGeneCommandSet(
            genename     => $genename,
            commandset   => {},
            filerank     => $filerank++,
        );
        my $commandset = $genecom->get_commandset();

        shift(@file) while @file && $file[0] =~ m/^\s*$|^\s*#/;

        # Parse other optional fields (right now, only "percontig")
        while (@file && $file[0] =~ m/^\s*(percontig|otherkeyTODO)\s*=\s*(\S+)\s*$/i) {
            my ($key,$val) = ($1,$2);
            if ($key =~ m/^(percontig|otherkeyTODO)$/i) { # boolean fields
                $val = ($val =~ m/^(|f|false|0|no|n)$/i) ? 0 : 1;
            }
            $key = lc $key;
            $genecom->$key($val); # '$key' must be a legal field of $genecom
            shift(@file) while @file && $file[0] =~ m/^\s*$|^\s*#/;
        }
            
        my $command_counter = 0;
        while (@file) {
            shift(@file) while @file && $file[0] =~ m/^\s*$|^\s*#/;
            last if !@file;

            # Expect "(pre|post)?commands"
            last if $file[0] !~ m/^\s*(pre|post)?commands\s*$/i;
            my $blocktype = lc ($1 || "");
            shift(@file);

            my @coms = ();
            while (@file && $file[0] !~ m/^\s*endcommands\s*$/i) {
                my $line = shift(@file);
                #next if $line =~ m/^\s*$|^\s*#/;
                chomp($line);
                $line =~ s/\s+$// if $line =~ m#\\\s+$#; # make sure continuation lines don't have trailing blanks
                push(@coms,$line);
            }

            unshift(@file,"(EOF)\n") unless @file; # for error message
            my $endcomkeyword = shift(@file);
            die "Error: unparsable line in '$filename' (expected \"endcommands\" keyword), got:\n$endcomkeyword"
                unless $endcomkeyword =~ m/^\s*endcommands\s*$/i;

            my $command_obj = new PirObject::MfAnnotGeneCommands(
               genename => $genename,
               bashcommands => \@coms,
            );

            my $command_key = $blocktype ? $blocktype : $command_counter++;
            if (exists $commandset->{$command_key}) {
                die "Error in '$filename': duplicate command block '$command_key' for gene '$genename'.\n";
            }

            die "Error in '$filename', gene '$genename', command block '$command_key': all commands are blank?!?\n"
                if !@coms || grep(/^\s*$|^\s*#/,@coms) == @coms;

            $commandset->{$command_key} = $command_obj;
        }

        die "Error in '$filename': unparsable line in '$genename':\n",$file[0],"\n"
            if @file && ! exists $commandset->{"0"};

        die "Error in '$filename': no normal command block specified for gene '$genename'?!?\n"
            unless exists $commandset->{"0"}; # at least one "command" block

        # Save MfAnnotGeneCommands object into MfAnnotExternalProgs object
        $genecoms->{$genename} = $genecom;
    }

    $self->set_geneprogs($genecoms);
    $self;
}
