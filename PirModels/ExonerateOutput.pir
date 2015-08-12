
#
# Output from Exonerate.
#

- PerlClass PirObject::ExonerateOutput
- InheritsFrom  PirObject
- FieldsTable

# Field name             Sing/Array/Hash  Type            Comments
#---------------------- ---------------   --------------- -----------------------
command                 single            string          Command line
report                  array             <ExonerateReport>

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: ExonerateOutput.pir,v 1.2 2008/08/19 20:32:05 riouxp Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub FillFeaturesFromTextOutput {
    my $self     = shift;
    my $tab      = shift;
    
    my $report = [];
    for (;;) {
        last if @$tab == 0;
        my @c4 = ();
        push(@c4,shift(@$tab)) while @$tab && $tab->[0] !~ m#^C4 Ali#;
        
        if ($c4[0] =~ /^Command line:\s*(.+)/){
        $self->set_command($1);
        }
        else {
        my $obj = new PirObject::ExonerateReport();
        $obj->FillFeaturesFromC4Report(\@c4);
        push(@$report,$obj);
        }
        shift(@$tab) if @$tab;
    }
    $self->set_report($report);
}


#my $report = [];
#foreach my $line (@$lines) {
#        my $obj = new PirObject::ExonerateReport();
#        $obj->FillFeaturesFromTextReport($line);
#        push(@$report,$obj);
#    }

#    $obj->set_titre("Candide");
#    $obj->titre("Candide");


