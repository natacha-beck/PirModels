
#
# Used in order to parse alignement output of HMMsearch.
#

- PerlClass PirObject::HMMAlis_for_Ali
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct          Type             Comments
#---------------------- --------------- ---------------  -----------------------
HMMalis                 array           <HMMAli_for_Ali>

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: HMMAlis_for_Ali.pir,v 1.1 2011/03/25 23:25:36 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

sub FillFeaturesFromTextOutput {
  my $self     = shift;
  my $tab      = shift;
  
  my $is_GS    = 0;
  my $cnt      = 0;
  my $Each_ali = {};
  foreach my $line (@$tab) {
    $is_GS    = 1 if $line =~ m/^#=GS/ && $is_GS == 0;
    
    if ($is_GS == 1) {
      if ($line =~ m/^\n/ && $is_GS ==1) {
        $is_GS = 2;
        $cnt   = 0;
      }
      else {
        my ($id,$start,$end,$ext) = ($1,$2,$3,$4) if $line =~ m/#=GS\s+(\w+)\/(\d+)\-(\d+)\s+DE\s+\[subseq from\]\s+(\w+)/;
        my $header = $id eq $ext ? "$id" : "${id}$ext";
        
        $Each_ali->{$cnt} = { id     => $id,
                    header => $header,
                    start  => $start,
                    end    => $end,
                  };
        $cnt++;
      }
    }
    if ($is_GS == 2) {
      next if ($line =~ m/^#=GC PP_cons/);
      next if ($line =~ m/^#=GC FF/);
      next if ($line =~ m/^#=GC RF/);
      next if ($line =~ m/^\/\//);
      if ($line =~ m/^\n/) {
        $cnt = 0;
        next;
      }
      my $ali = $Each_ali->{$cnt}->{ali} || "";
      my $hmm = $Each_ali->{$cnt}->{hmm} || "";
      if ($line !~ m/^#=GR/) {
        my @tab  = split(/\s+/,$line);
        $ali .= $tab[-1];
        $Each_ali->{$cnt}->{ali} = $ali;
      }
      else {
        my @tab = split(/\s+/,$line);
        $hmm .= $tab[-1];
        $Each_ali->{$cnt}->{hmm} = $hmm;
        $cnt++;
      }
    }
  }
  
  my $All_ali = [];
  foreach my $key (keys %$Each_ali) {
    my $ali = new PirObject::HMMAli_for_Ali ( id        => $Each_ali->{$key}->{id},
                          header    => $Each_ali->{$key}->{header},
                          start_ori => $Each_ali->{$key}->{start},
                          start     => $Each_ali->{$key}->{start}, 
                          end_ori   => $Each_ali->{$key}->{end},
                          end       => $Each_ali->{$key}->{end},
                          ali_seq   => $Each_ali->{$key}->{ali},
                          ali_hmm   => $Each_ali->{$key}->{hmm},
                        );
    push(@$All_ali,$ali) if $ali;
  }
  $self->set_HMMalis($All_ali);
}
