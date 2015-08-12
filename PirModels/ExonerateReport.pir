
#
# A single Exonerate report.
#

- PerlClass PirObject::ExonerateReport
- InheritsFrom  PirObject
- FieldsTable

# Field name            Sing/Array/Hash Type            Comments
#---------------------- --------------- --------------- -----------------------
query                   single          string
target                  single          string
model                   single          string
raw_score               single          string
query_range             single          string
query_start             single          int4
query_stop              single          int4
target_range            single          string
target_start            single          int4
target_stop             single          int4
protfeatures            array           <ExonerateFeature>
dnafeatures             array           <ExonerateFeature>

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: ExonerateReport.pir,v 1.6 2010/06/08 20:28:54 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub FillFeaturesFromGFFReport {
    my $self     = shift;
    my $lines    = shift;
    my $whichone = shift || "Unknown";

    die "Need to specify which array to fill.\n"
        unless $whichone =~ m#^(dna|prot)features$#;
    
    my $features = [];
    foreach my $line (@$lines) {
        my $obj = new PirObject::ExonerateFeature();
        $obj->FillFromLine($line);
        push(@$features,$obj);
    }

    $self->$whichone($features);
 
}


sub FillFeaturesFromC4Report {
 
my $self     = shift;
my $lines    = shift;
  
 
for (my $i=0; $i<@$lines;$i++) {
    if ($lines->[$i] =~ /^\s*Query:\s*(.+)/){
        $self->set_query($1);next;
    }
    if ($lines->[$i]  =~ /^\s*Target:\s*(.+)/){
        $self->set_target($1);next;
    }
    if ($lines->[$i]  =~ /^\s*Model:\s*(.+)/){
        $self->set_model($1);next;
    }
    if ($lines->[$i]  =~ /^\s*Raw\s*score:\s*(.+)/){
        $self->set_raw_score($1);next;
    }
    if ($lines->[$i]  =~ /^\s*Query\s*range:\s*(.+)/){
        my $range = $1;
        my ($start,$stop) = ($range =~ m#(\d+)\D+(\d+)#);
        $self->set_query_range($range);
        $self->set_query_start($start);
        $self->set_query_stop($stop);
        next;
    }
    if ($lines->[$i]  =~ /^\s*Target\s*range:\s*(.+)/){
        my $range = $1;
        my ($start,$stop) = ($range =~ m#(\d+)\D+(\d+)#);
        $self->set_target_range($range);
        $self->set_target_start($start);
        $self->set_target_stop($stop);
        last;
    }
}

my @dna  =();
for (my $i=0; $i<@$lines;$i++) {
    next if $lines->[$i] !~ m/START OF GFF/;
    my $start = $i;
    for (my $k = $i;$k < @$lines;$k++) {
        next unless $lines->[$k] =~ m/END OF GFF/;
    my $end = $k;
    my @SUBREPORT = @$lines[ $start .. $end ];
    
    
    my $reptype = "";
    foreach (@SUBREPORT){
       $reptype = "protfeatures" if ($_ =~ m/type Protein/);     #$reptype = "protfeature"
       $reptype = "dnafeatures" if ($_ =~ m/type DNA/);
    }
    
    
    @SUBREPORT = grep (!/^#/,@SUBREPORT);
    $self->FillFeaturesFromGFFReport(\@SUBREPORT,$reptype);
    }
}
}



