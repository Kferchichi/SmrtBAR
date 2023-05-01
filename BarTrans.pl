#! /usr/bin/perl
use strict;
use warnings;
use Cwd;
use v5.10;                     # minimal Perl version for \R support
use utf8;                      # source is in UTF-8
#use taint mode;
use warnings qw(FATAL utf8);   # encoding errors raise exceptions
use open qw(:utf8 :std);       # default open mode, `backticks`, and std{in,out,err} are in UTF-8
use Algorithm::NeedlemanWunsch;# install following the manual 
                               
my $this_primer = "";
my %primer_list = ();
my $j = 0;

 print "Barcode_trans.pl by Michael Krug modified by Khaoula Ferchichi\nEnjoy it!
        Please provide some informations: Did you use specific primers?\n\n
        please type [y/n]:";

my $input=<STDIN>;
my $input2;

chomp ($input);

if ($input =~ /y/i ){
    print "\nOk then, please write the primers file name: ";
    $input2=<STDIN>;
    chomp $input2;
    print "\n$input2 does not exist\n" unless -e $input2;
    exit unless -e $input2;
    print "\nAlright, we get the file!\nTranslation starts.......\n" ;
}

my ($fastq, $translation_file, $primer_table);

if(@ARGV){
    $fastq=$ARGV[0];
    $translation_file=$ARGV[1];    

} else {
    print "\nUsage: perl Barcode_trans.pl [Amplicon_analysis.fastq] [translation_file.txt]\t try again\n";
 die;
 
}

my %trans;
open (TAB,"<",$translation_file) || die $!,"\n";
while (<TAB>){
  if (/(\w+),(\w+)/){
    $trans{$1}=$2;
  }
}  

$primer_table = $input2;
my $pref = $fastq;
$pref =~ s/\.amplicon.analysis\.fastq//i;

open FASTQIN, $fastq;
my $fasta = $fastq;
my $junk = $fastq;
#create fasta and junk
$fasta =~ s/.fastq/.fasta/i;
open FASTA,">",$fasta;
$junk =~ s/.fastq/.junk.fasta/i;
open JUNK, ">",$junk;

  my(@pname, @pseq, @pdir, @primer_name);
open (PRIMER, "<", $primer_table) || die "cannot $!";
while(<PRIMER>){
  chomp;
  next unless length;      #get rid of empty lines
  if(/(\w+),(\w+),(\w+),(\w+)/i){
    #print " primername: $1, primersequence: $2\n";
    push @pname, $1;
    push @pseq, $2;
    push @pdir, $3;
   }
   else
      {
	  next; 
	  }
   }
	

#create list of nonredundant primer names @pname --> @primer_name

my @used_primer = &sort_used( @pname );
my $u = "";

print "List of primers\n";

foreach $u ( @used_primer)
	{
	print "$u\n";
	}
#Algorithm::NeedlemanWunsch->local;
my (@a,@b,@a2,@b2);
my ($countr,$junkctr);
while(
  defined(my $shead = <FASTQIN>) &&
  defined(my $sseq = <FASTQIN>) &&
  defined(my $qhead = <FASTQIN>) &&
  defined(my $qseq = <FASTQIN>)
){
  
  
  substr($shead, 0, 1, '>');
  $shead =~ s/\R//g;  #   \R =  Linebreak
  

  #change BC0xx to name 
  if ($shead =~ /(BC\d{3})\-\-BC\d{3}/i){
    my $name = $trans{$1};
     print $name . "\n" ;
    $shead =~ s/$1/$name/;
    $shead =~ s/\>Barcode/\>/i;
  }

  # a file with all sequences
  print FASTA $shead,"\n",$sseq;
  
  #get first n letter (from 0 to 250) of the sequence...
  my $start = substr ($sseq, 0, 250);
  #print $start,"\n";
  my $junktmp=0;

  print "\nSorting reads  ",$shead,"\n";
  for(my $i=0;$i<=$#pseq;$i++){
    #print "find primer \t\t",$_,"\nin sequence \t\t ",$start,"\n";
    my $matcher = Algorithm::NeedlemanWunsch->new(\&score_sub);
    $matcher->local(1);
    @a=split //, $start;
    @b=split //, $pseq[$i];
    my $score = $matcher->align(
      
               \@a,     #longer
               \@b,     #shorter
               {   align     => \&on_align,
                   shift_a => \&on_shift_a,
                   shift_b => \&on_shift_b,
                   select_align => \&on_select_align
               });
# this is the threshold defining the primer hit success    
      if ($score>10){
        
        
      #*********************************************
      #we could start a blast search on $sseq here
      #**********************************************
        my $chimera=0;
        #check for chimeric sequences here
        my $matcher2 = Algorithm::NeedlemanWunsch->new(\&score_sub);
        #$matcher2->local(1);
        @a=split //, substr($sseq,20,(length($sseq)/2)-10);   #first half of sequence
        #print "\na: ",$#a,"\n",@a;
        my $tempb=substr($sseq, -(length($sseq)/2)-10,(length($sseq)/2)-10 ); #second half
        @b=split //, reverse_complement_IUPAC($tempb);  #revcomplement 
        #print "\nb: ",$#b,"\n",@b;
        #exit;
        #my $score2=50;
        my $score2 = $matcher2->align(
        
                 \@a,
                 \@b,
                 {   align     => \&on_align,
                     shift_a => \&on_shift_a,
                     shift_b => \&on_shift_b,
                     select_align => \&on_select_align
                 });
        #print "\nscore2: ",$score2;
        
          if ($score2>20){
            #print "\n CHIMERA $sseq!!!!! \n";
            $chimera=1;
            $countr++;
            #exclude chimeras
            $junktmp=0;
            #exit;
            }else{
            #print "\nnot chimeric:\n $sseq";
            }
          my $line="$shead\n$sseq";
          my $lineR=$shead."_reversed".reverse_complement_IUPAC($sseq)."\n";

        unless ($chimera){
         

         
	      for( $j = 0; $j<=$#used_primer; $j++ )
		     {
		     $this_primer = $used_primer[ $j ];
		     if( $pname[ $i ] =~ /$this_primer/i && $pdir[ $i ] =~ /F/i )
		   	    {
				print "$line\n" ;
			    push @{ $primer_list{ $this_primer } }, $line
			    }
		     elsif( $pname[ $i ] =~ /$this_primer/i && $pdir[ $i ] =~ /R/i )
			    {
				print "$lineR\n" ;
			    push @{ $primer_list{ $this_primer } }, $lineR
			    }
		     }
          
         
        $junktmp=1;
        $i=1000;
        
        #make it stop ;)
        }
      }
    }
  # fill junk file
    unless($junktmp){
      my $junkline="$shead\n$sseq";
      $junkctr++;
      print JUNK $junkline;
  }
 
  
  #exit unless $countr < 15;
}
close JUNK;
close FASTQIN;
#print the alignments
my $no_of_reads = 0; 
my $p = "";
my @n_reads = 0;
 for( $j = 0; $j<=$#used_primer; $j++ )
    {
    $this_primer = $used_primer[ $j ];
            $no_of_reads = 0; 
	foreach $p ( @{ $primer_list{ $this_primer } } )
{
       #$no_of_reads = @n_reads; 
	if ( $p ne "")
{
       $no_of_reads++;
}
    }
 if ( $no_of_reads > 0 )

{
       open( PRIMOUT, ">>", "$fasta-$this_primer.fasta" );
	   foreach $p ( @{ $primer_list{ $this_primer } } )
		   {
print "found:".$p ."\n";
		   
print PRIMOUT $p . "\n";
		   }
	close PRIMOUT;
	    }
    }


#print "\nthis_primer contains ",$#used_primer," sequences\n";
print "\nThere are $countr Chimeras";
print "\nJunk contains $junkctr sequences\n\n*********************\n\tDone, Thank you for using Barcode_trans!\n";

#kkkkkkk

my $bell = chr(7);
print $bell;

#++++++++++++++++
# subroutines


#filter double array elements
sub uniq {
    my %seen;
    grep !$seen{$_}++, @_;
}
#reverseer
sub reverse_complement_IUPAC {
        my $dna = shift;
        #print $dna;
        # reverse the DNA sequence
        my $revcomp = reverse($dna);
        #print "\n",$revcomp;
        # complement the reversed DNA sequence
        $revcomp =~ tr/ABCDGHMNRSTUVWXYabcdghmnrstuvwxy/TVGHCDKNYSAABWXRtvghcdknysaabwxr/;
        #print "\n",$revcomp,"\nover";
        return $revcomp;
        
}

sub sort_used 
	{
	my $i = 0;
	my @item =@_;
	my @result = ();
	my $no_of_item = @item;
	for( $i = 0; $i < $no_of_item; $i++ )
		{
		#print $item[ $i ] . "\n";
		if ( $i < $no_of_item - 1 )
			{
			if ( $item[ $i ] ne $item[ $i + 1 ] )
				{
				push @result, $item[ $i ];
				}
			}
		else
			{
			push @result, $item[ $i ];
			}
		}
	return @result;
	}

#use needlemanwunsch
### scoring function:
sub score_sub {
        if (!@_) {
            return -2; # gap penalty
        }

        return ($_[0] eq $_[1]) ? 1 : -1;
    }

# callbacks
## callbacks that print something useful
## prints an 'alignment string' in the order of the  
## recursion of the dynamic programming algorithm 
## print "-" only on match
sub on_align  {  "align", " " , $a[$_[0]], ($a[$_[0]] eq $b[$_[1]] ) ? "-" : " ", $b[$_[1]], "\n" }; 
sub on_shift_a {   "gap  ", "" , $a[$_[0]], "\n" };
sub on_shift_b {  "gap  ", "   " , $b[$_[0]], "\n"};
### Dumb select, need to return one of the keys for alternative 
### alignments with equal score. Here, we always take the first option, but don't print it.

sub on_select_align {  return (keys (%{$_[0]})) [0]};



#######printing versions below, use in verbose output or debug
#sub on_align  { print "align", " " , $a[$_[0]], ($a[$_[0]] eq $b[$_[1]] ) ? "-" : " ", $b[$_[1]], "\n" }; 
#sub on_shift_a {  print "gap  ", "" , $a[$_[0]], "\n" };
#sub on_shift_b { print "gap  ", "   " , $b[$_[0]], "\n"};
#sub on_select_align { print "(select_align)\n"; return (keys (%{$_[0]})) [0]};

