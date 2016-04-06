
#
# Represantation of the Masterfile.
#

- PerlClass PirObject::Masterfile
- InheritsFrom  PirObject
- FieldsTable

# Field name            Struct  Type                Comments
#---------------------- ------- ------------------- -----------------------
filename        single  string                      Filename of masterfile
header          array   string                      Multiline comment at top of masterfile. If already there, they must be removed
comment         array   string                      Multiline comment at top of masterfile. If already there, they must be kept.
contigs         array   <MasterfileContig>          Contig sequences and annots             

- EndFieldsTable

- Methods

our $RCS_VERSION='$Id: Masterfile.pir,v 1.40 2012/01/21 20:53:09 nbeck Exp $';
our ($VERSION) = ($RCS_VERSION =~ m#,v ([\w\.]+)#);

# Reads a masterfile from a file and populates a PirObject::Masterfile structure with it.
sub ObjectFromMasterfile { # yamp, yet another masterfile parser, and an ugly one too.
  my $self        = shift;
  my $filename    = shift;
  my $RemoveIupac = shift || 0;
  
  my $fh = new IO::File "<$filename"
    or die "Can't read from '$filename': $!\n";
  my @lines = <$fh>; # slurp it all in!
  $fh->close();
  chomp @lines;

  my $mf = $self->new( filename => $filename );
  
  my $row = 0;

  my $header         = [];
  my $comment_header = [];
  my $after_header   = 0;
  while ($row < @lines && $lines[$row] !~ m#^>#) {
    if ($lines[$row]  =~ m#^;;\s*end mfannot#) {
      $row++;
      $after_header = 1;
      next;
    }
    push(@$header,$lines[$row++])         if $after_header == 0;
    push(@$comment_header,$lines[$row++]) if $after_header == 1;
  }
  $mf->set_header($header);
  my $scalar = scalar(@$header);
  my $MFheaderisDef = scalar(@$comment_header);
  $MFheaderisDef == 0 ? $mf->set_comment($header) : $mf->set_comment($comment_header) ;

  my $contigs = [];

  # This loops parses each contig.
  for (;;) {
    last if $row >= @lines;

    my $contig = PirObject::MasterfileContig->new();

    my ($faname,$namecomments) = ($lines[$row++] =~ m#^>\s*(\S+)(.*)#)
      or die "Can't parse header line of masterfile '$filename'. Line is:\n" . $lines[$row];
    $namecomments =~ s/\s*$//;
    $contig->set_name($faname);
    $contig->set_geneticcode($1) if $namecomments ne "" && $namecomments =~ m/\/trans\s*=\s*(\d+)/i;
    $contig->set_namecomments($namecomments) if $namecomments ne "";

    my $seq = "";
    my %annotexp = ();  # expected

    my $allannots = [];

    my $seqpos = 0; # in computer coordinates, not biological coordinates!

    my $linenumber = 0; # arbitrary counter
    while ($row < @lines) {
    
      $linenumber++;
      my $line = $lines[$row++];
      next if $line =~ m#^\s*$#; # ignore blank lines
      $row--, last if $line =~ m#^>#; # That means 'next contig'!
    
      if ($line =~ m#^\s*\d*\s*([^;].*)#) {
        my $dna = $1;
        next if $dna =~ m/^\s+$/;
        $dna =~ tr/ \r\n\t//d;
        if ($RemoveIupac == 0) {
          die "Bad characters in sequence line?!??\nLine: $line\n" 
            unless $dna =~ m#^[acgtnN!]+$#;
          $seq .= $dna; # includes special characters such as '!'
          $seqpos += ($dna =~ tr/acgtACGTnN/acgtACGTnN/) ; # count without the '!'s.
        }
        else {
          die "Bad characters in sequence line?!??\nLine: $line\n" 
          unless $dna =~ m#^[uUyrwskmbdhvxUYRWSKMBDHVXACGTacgtnN!]+$#;
          $seq .= $dna; # includes special characters such as '!'
          $seqpos += ($dna =~ tr/uUyrwskmbdhvxUYRWSKMBDHVXacgtACGTnN/uUyrwskmbdhvxUYRWSKMBDHVXacgtACGTnN/);# count without the '!'s.
          $seq =~ tr/uUyrwskmbdhvxUYRWSKMBDHVX/TTNNNNNNNNNNNNNNNNNNNNNN/;
        }
        next;
      }
    
      if ($line =~ m#^;\s*([G])-(\S+)\s+(<==\*?|\*?==>)\s+(start|end|point)(.*)#) {
        my ($type,$name,$arrow,$startend,$comment) = ($1,$2,$3,$4,$5);
        my $intron_type = "";
        $intron_type = $1 if $line =~ m#/group=(\S+)#;
    
        my $multicomment = [];
        for (;$row < @lines;$row++) {
          last unless $lines[$row] =~ m#^;# && $lines[$row-1] =~ m#\\\s*$#;
          push(@$multicomment,$lines[$row]);
        }
        my $pos = $arrow =~ />/ ?  
        ($startend eq "start" || $startend eq "point" ?  $seqpos+1 : $seqpos)
        : ($startend eq "end"   ?  $seqpos+1 : $seqpos);
    
        my $annotkey = lc "$type-$name";
    
    
        ### structure of date : a hash called annotexp, contains a 
        ### table. This on contains an other hash for storing annotation
        ### The last hash array has 3 keys :
        ### 1 -> start : if it's defined, start pos is defined in annotation
        ### 2 -> end : if it's defined, end pos is defined in annotation  
        ### 3 -> annot : contains the annotation itself   
    
        if ($startend eq "point") {
          my $annot =  new PirObject::AnnotPair( type       => $type,
                               introntype => $intron_type,
                               genename   => $name,
                               direction  => $arrow,
                              );
    
             $annot->SetMultipleFields(
                        startpos          => $pos,
                        endpos            => $pos,
                        startline         => $line,
                        startmulticomment => $multicomment,
                        startlinenumber   => $linenumber,
                        );
          push(@$allannots,$annot);
        }
        else {
          if (defined $annotexp{$annotkey}){
            my $table = $annotexp{$annotkey};
            if ($startend eq "start"){
              my $count=0;
              my $hasdefined = 0;    # a variable that allows to 
              START : while ($count < scalar(@$table)){      # goo over the table containing annotation
                my $infos = $table->[$count];
                my $state = $infos->{'startend'};   # here we get if it's start or stop
                if ($state eq 'start' or $state eq 'finish') {            # It mean start is already defined
                  $count++; 
                  next START;
                }
                else {                              # Means that end 
                  my $annot = $infos->{'annotation'};
                     $annot->SetMultipleFields(
                          startpos          => $pos,
                          startline         => $line,
                          startmulticomment => $multicomment,
                          startlinenumber   => $linenumber,
                                );
                  push(@$allannots,$annot);
                  $infos->{'startend'} = 'finish';
                  $hasdefined = 1;
                  last START;
                }
              }
              if ($hasdefined == 0) {   # it means that annotation array has been running without finding an empty
                            #case, a corresponding annotation in existing annotation
                my  $newinfos = {};
                $newinfos->{'startend'} = 'start';   # It's just to define the thing
                my $annot =  new PirObject::AnnotPair(
                          type           => $type,
                          introntype      => $intron_type,
                          genename        => $name,
                          direction       => $arrow,
                                  );
                   $annot->SetMultipleFields(
                          startpos          => $pos,
                          startline         => $line,
                          startmulticomment => $multicomment,
                          startlinenumber   => $linenumber,
                              );
                $newinfos->{'annotation'} = $annot;
                push (@$table, $newinfos);
              }
            }  # End of case if it's start
            else {           #  case 
              my $count=0;
              my $hasdefined = 0;    # a variable that allows to 
              STOP : while ($count < scalar(@$table)){      # goo over the table containing annotation
                my $infos = $table->[$count];
                my $state = $infos->{'startend'};   # here we get if it's start or stop
                if ($state eq 'end' or $state eq 'finish' ) {            # It mean start is already defined
                  $count++; 
                  next STOP;
                }
                else {                              # Means that end 
                  my $annot = $infos->{'annotation'};
                  $annot->SetMultipleFields(
                          endpos          => $pos,
                          endline         => $line,
                          endmulticomment => $multicomment,
                          endlinenumber   => $linenumber,
                  );
                  push(@$allannots,$annot);
                  $infos->{'startend'} = 'finish';
                  $hasdefined = 1;
                  last STOP;
                }    
              } 
              if ($hasdefined == 0) { # it means that annotation array has been running without finding an empty
                          #case, a corresponding annotation in existing annotation
                my  $newinfos = {};
                $newinfos->{'startend'} = 'end';   # It's just to define the thing
                my $annot =  new PirObject::AnnotPair(
                        type       => $type,                                       
                        introntype => $intron_type,
                        genename   => $name,
                        direction  => $arrow,
                                  );
                   $annot->SetMultipleFields(
                        endpos           => $pos,
                        endline          => $line,
                        endmulticomment  => $multicomment,
                        endlinenumber    => $linenumber,
                                  );
                $newinfos->{'annotation'} = $annot;
                push (@$table, $newinfos);
              }
            }  # End of case if it's stop
          } # End of if it's : 
          else {
            my $annot =  new PirObject::AnnotPair(
                        type       => $type,
                        introntype => $intron_type,
                        genename   => $name,
                        direction  => $arrow,
                        );
            if ($startend eq "start") {
              $annot->SetMultipleFields(
                        startpos          => $pos,
                        startline         => $line,
                        startmulticomment => $multicomment,
                        startlinenumber   => $linenumber,
                        );
            } 
            elsif ($startend eq "end") { # $startend eq "end"
              $annot->SetMultipleFields(
                        endpos           => $pos,
                        endline          => $line,
                        endmulticomment  => $multicomment,
                        endlinenumber    => $linenumber,
                        );
            }
          my  $infos = {};  # hash array containing, start stop, and the annot
          $infos->{'startend'} = $startend;   # It's just to define the thing
          $infos->{'annotation'} = $annot;
          my $table = [];
          push (@$table, $infos);     # we put the hashing table in the table
          $annotexp{$annotkey} = $table;   
        }
      next;
      }  # End of if line is like that
    }
    if ($line =~ m#^;#) {
    my $multicomment = [];
    for (;$row < @lines;$row++) {
    last unless $lines[$row] =~ m#^;# && $lines[$row-1] =~ m#\\\s*$#;
    push(@$multicomment,$lines[$row]);
    }
    my $annot = new PirObject::AnnotPair(
    type              => "C",  # a comment
    startpos          => $seqpos+1,
    startline         => $line,
    startmulticomment => $multicomment,
    startlinenumber   => $linenumber,
    );
    push(@$allannots,$annot);
    next;
    }
    die "Unexpected line:\n$line\n";
    } # loop through lines of contig

         #  checking annotations
         foreach my $annot (@$allannots) {
           if ($annot->type eq 'G') {
             # For the genename, deleting the _X : the number of each copy
             my $newgename = $annot->genename;
             $newgename =~ s/\_\d+//;

             if ($newgename =~ m#-I\d+-(\S+)$#) { # special case for G-cox1_2-I3-orf232
               $newgename = $1;
             }
     
             $annot->set_genename($newgename);  

             # If it's a gene
             if ($annot->genename =~ /Sig-(.+)$/){
               $annot->set_genename ($1);
               $annot->set_type("S")
             }
             elsif ($annot->genename =~ /-E\d+$/ || $annot->genename =~ /-E\d+-\S+$/) {                                       # If it's an exon  
               my @genenamecut = split ("-", $annot->genename);                    #  Split the name by -
               $annot->set_genename ($genenamecut[0]) if $genenamecut[0] ne "";    #  Give only the genename to the exon
               $annot->set_type("E");                                              #  Se t a new type
             }
             elsif ($annot->genename =~ /-I\d+$/ || $annot->genename =~ /-I\d+-\S+$/) {                                       # If it's an exon  
               my @genenamecut = split ("-", $annot->genename);                    #  Split the name by -
               $annot->set_genename ($genenamecut[0]) if $genenamecut[0] ne "";    #  Give only the genename to the exon
               $annot->set_type("I");                                              #  Se t a new type
             }
             elsif ($annot->genename =~ /(trn[\w|?]*)\([\w|?]*\)/) {       # It's a tRNA
               my $newtrnaname = $1;                          # Just take trnA.... as gene name
               $annot->set_genename ($newtrnaname); 
             }
           }
         }
         undef %annotexp;
         $contig->set_sequence($seq);
         $contig->set_annotations($allannots);
         my $seqlen = ($seq =~ tr/ACGTNacgtn/ACGTNacgtn/); # count them
         $contig->set_sequencelength($seqlen);
         push(@$contigs,$contig);
  } # loop through contigs
  $mf->set_contigs($contigs);
  $mf;
}

sub ObjectToMasterfile {
  my $self     = shift;
  my $filename = shift;
  # Print masterfile header
  my $fh = new IO::File ">$filename"
    or die "Can't write to '$filename': $!\n";
  
  my $header = $self->get_header() || [];
  pop(@$header) while @$header && $header->[-1] =~ m#^\s*$#;
  if (@$header) {
    print $fh join("\n",@$header),"\n";
  }
  
  my $contigs = $self->get_contigs() || [];
  foreach my $contig (@$contigs) {
    my $name         = $contig->get_name();
    my $namecomments = $contig->get_namecomments() || "";
  
    print $fh "\n\n";
    print $fh ">$name$namecomments\n";
  
    my $posannots = [];
    my $annots = $contig->get_annotations();
    my $fullseq = $contig->get_sequence(); # contains '!'s !
    my %start_ac = ();
    my %stop_ac  = ();
  
    foreach my $annot (@$annots) {
      my $type  = $annot->type(); 
      next unless $type eq 'AC';
      my $start = $annot->startpos();
      $start_ac{$start}=1;  # biol coordinates
      my $stop  = $annot->endpos();
      $stop_ac{$stop}=1;
      
    }
  
    my $num = 0; # $num will be bio coords
    for ( my $i = 0; $i < length($fullseq) ; $i++) {
      my $c = substr($fullseq,$i,1);
      next if $c eq '!';
      
      $num++; # $num is bio coords
      
      if ( $start_ac{$num} || $stop_ac{$num} ) {
        if (substr($fullseq,$i-1,1) ne '!' && $start_ac{$num}) {
          substr($fullseq,$i,0) = "!";
          $i++;
        }
        if (substr($fullseq,$i,1) ne '!' && $stop_ac{$num}) {
          substr($fullseq,$i+1,0) = "!";
          $i++;
        }
      }
    }
  
    ANNOT : foreach my $annot (@$annots) {
      my $type  = $annot->type() ;
      my $start = $annot->startpos();
      next if ($type eq "AC" );
      
      my $end   = $annot->endpos();  # can be undef
      my $arrow = $annot->get_direction() || ">";  # <== or ==> or <==* or *==> or undef
      
      if ($arrow =~ m#>#) {
        push(@$posannots, [ $start-1, ($annot->startlinenumber() || 0),  "S", $annot]) if defined($start);
        push(@$posannots, [ $end,     ($annot->endlinenumber()   || 0),  "E", $annot]) if defined($end);
      }
      else {
        push(@$posannots, [ $start,   ($annot->startlinenumber() || 0),  "S", $annot]) if defined($start);
        push(@$posannots, [ $end-1,   ($annot->endlinenumber()   || 0),  "E", $annot]) if defined($end);
      }
    }
    my $etape = 1;
    
    @$posannots = sort { # Modified by T. HOELLINGER
      # Simple case, nucleotide position is different:
      return $a->[0] <=> $b->[0]    if $a->[0] != $b->[0];
      
      # Simple case, line numbers are available and > 0, so compare them
      return $a->[1] <=> $b->[1]    if $a->[1] && $b->[1];
      
      # The new sorting function
      my $fulllinea = " ";       # G-genname ==> start ;; comment
      my $fulllineb = " ";       #    ||     ||
      my $namea = " ";       # the genename
      my $nameb = " ";       #   ||    ||
      my $arrowa = " ";      # ==> or <==
      my $arrowb = " " ;      #  ||    ||
      my $startorenda = " " ; # as it said start or end
      my $startorendb = " " ; #         ||      ||
      
      #  Take the line
      $fulllinea = $a->[3]->startline if ($a->[2] eq "S");  
      $fulllinea = $a->[3]->endline   if ($a->[2] eq "E");
      $fulllineb = $b->[3]->startline if ($b->[2] eq "S");
      $fulllineb = $b->[3]->endline   if ($b->[2] eq "E");
      
      #  Cut the line were there are ;;
      my @cutlinea = split (";;", $fulllinea);    # do a split
      my @cutlineb = split (";;", $fulllineb);    # do a split
      
      #  Cut the line and identify pattern
      my $linea = $cutlinea[0] || "";  # Only take the part before ;;, Delete comments
      my $lineb = $cutlineb[0] || "";  #     ||        ||
      $linea =~ s/^\s*//;           # Delete the spaces before, at the beginning of the description
      $lineb =~ s/^\s*//;           #     ||        ||
      $linea =~ s/\s*$//;           # Delete the spaces at the end of the descriptio
      $lineb =~ s/\s*$//;           #     ||        ||
      $linea =~ /([\w|\_\-\d\(\)\?]+)\s*(==>|<==)\s*(start|end)/;
      $namea = $1 || "";            # Get the genename
      $arrowa = $2 || "";           # Get the arrow
      $startorenda = $3 || "";      # Get the start or the end
      $lineb =~ /([\w|\_\-\d\(\)\?]+)\s*(==>|<==)\s*(start|end)/;
      $nameb = $1 || "";
      $arrowb = $2 || "";
      $startorendb = $3 || "";
      
      if ($arrowa eq "==>" and $arrowb eq "==>" and $startorenda eq "start" and $startorendb eq "start") { 
        return $namea cmp $nameb;
      }
      elsif ($arrowa eq "==>" and $arrowb eq "==>" and $startorenda eq "end" and $startorendb eq "end") { 
        return $nameb cmp $namea;
      }
      elsif ($arrowa eq "==>" and $arrowb eq "==>" and $startorenda eq "start" and $startorendb eq "end") { 
        return $a->[2] cmp $b->[2];  # end before the start
      }
      elsif ($arrowa eq "==>" and $arrowb eq "==>" and $startorenda eq "end" and $startorendb eq "start") { 
        return $a->[2] cmp $b->[2];  # end before the start
      }
      elsif ($arrowa eq "<==" and $arrowb eq "<==" and $startorenda eq "start" and $startorendb eq "start") { 
        return $nameb cmp $namea;
      }
      elsif ($arrowa eq "<==" and $arrowb eq "<==" and $startorenda eq "end" and $startorendb eq "end") { 
        return $namea cmp $nameb;
      }
      elsif ($arrowa eq "<==" and $arrowb eq "<==" and $startorenda eq "start" and $startorendb eq "end") { 
        return $b->[2] cmp $a->[2];  # start before the end
      }
      elsif ($arrowa eq "<==" and $arrowb eq "<==" and $startorenda eq "end" and $startorendb eq "start") { 
        return $b->[2] cmp $a->[2];  # start before the end
      }     
      else { 
        return $fulllinea cmp $fulllineb;
      }
    }@$posannots;
    
    my $seqpos  = 0;
    my $charpos = 0;
    
    while (@$posannots) {
      my $annotinfo = shift(@$posannots);
      my ($atpos,$se,$annot) = @$annotinfo[0,2,3];
      my $name = $annot->get_genename();
      
      my $block = "";
      my $blockpos = $seqpos;
      while ($seqpos < $atpos) {
        my $char = substr($fullseq,$charpos,1);
        my $IsDef = !$char ? 1 : 0; 
        $block .= $char;
        $charpos++;
        $seqpos++ if $char ne '!';
      }
      if (substr($fullseq,$charpos,1) eq "!" && length($block) >= 4 && substr($block,-4,4) =~ m#!#) {
        $block .= "!";
        $charpos++;
      }
      if ($block) {
        &_FastaBlockToFH($block,$blockpos+1,$fh);
      }
      my $multicomment = [];
      if ($se eq "S") {
        print $fh $annot->get_startline(),"\n";
        $multicomment = $annot->get_startmulticomment();
      }
      else { # $se eq "E"
        print $fh $annot->get_endline(),"\n";
        $multicomment = $annot->get_endmulticomment();
      }
      if (@$multicomment) {
        print $fh join("\n",@$multicomment),"\n";
      }
    }
    
    my $block = $charpos < length($fullseq) ? substr($fullseq,$charpos) : "";
    if ($block) {
      &_FastaBlockToFH($block,$seqpos+1,$fh);
    }
  }
  $fh->close();
}

sub _FastaBlockToFH { # not a method
  my $seq = shift;  # may contain '!' characters!
  my $pos = shift;
  my $fh  = shift;

  while ($seq) {
    if (length($seq) > 60) {
       my $subseq = substr($seq,0,60);
       printf $fh "%6d  %s\n",$pos,$subseq;
       $pos += ($subseq =~ tr/ACGTNacgtn/ACGTNacgtn/); # count them
       $seq = substr($seq,60);
       next;
    }
    printf $fh "%6d  %s\n",$pos,$seq;
    last;
  }
}

# Utility routine that precomputes an internal hash the first
# time it's called.
sub GetContigByName {
  my $self       = shift;
  my $contigname = shift;

  if (!$self->{'!contigbyname!'}) {
    my $cache = $self->{'!contigbyname!'} = {};
    my $contigs = $self->get_contigs() || [];
    foreach my $contig (@$contigs) {
      my $name = $contig->get_name();
      next unless defined $name;
      $cache->{$name} = $contig;
    }
  }

  $self->{'!contigbyname!'}->{$contigname};  # returns undef if not found.
}

sub SortMasterfile
{
  my $self      = shift;
  my $direction = shift;
  my $contigs   = $self->contigs;

  @$contigs = sort {
    my $lenA = length($a->sequence);
    my $lenB = length($b->sequence);
    if($direction == 1) {
      $lenB <=> $lenA;
    }
    else {
      $lenA <=> $lenB;
    }
  }@$contigs;
}
