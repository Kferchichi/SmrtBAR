#! /usr/bin/perl -w

use strict;
use warnings;
use Cwd;
use utf8;
use File::Path;
use File::Copy;
use warnings qw(FATAL utf8);
use open qw(:utf8 :std);
use diagnostics;

####################################################################################################
#                                                                                                  #
#SmartyHiFi.pl                                                                                     #
#                                                                                                  #
#Pipeline created to analyse(demultiplex) multiplexed HiFi reads                                   #
#                                                                                                  #
#                                                                                                  #
# Release date: Februar 2022                                                                       #
#                                                                                                  #
####################################################################################################


   print "SmartyHiFi.pl by Khaoula Ferchichi\nEnjoy it!\n";

my $fastq_file;
my $barcodes_file;
my $in;
my $out;
my $final_out;
my $lima_file;
my $host_file;

#number of arguments varies between 2 and 3 depending on how the samples have been sequenced

if(@ARGV){
   $fastq_file=$ARGV[0];
    print "hifireads are: $fastq_file\n";
if (defined($ARGV[1])) {
   $barcodes_file=$ARGV[1];
    print "Barcodes are: $barcodes_file\n";

   }

	}
else {
    print "\nUsage: perl SmartyHiFi.pl [name].hifireads.fatsq [PacBio_barcodes].fasta\t try again\n";
die;
	}
my $data = $fastq_file;
   $data =~ s/\.hifireads\.fastq//i;

#please note that you need to write your own path where you package has been saved.
my $path = '/YOUR/PATH/TO/Package';                    #Path to lima and laa shell scripts

    print cwd,"\n\n";
#Create an OUTPUT subdirectory
    print "Creating an OUTPUT file \n";
    rmtree('OUTPUT');
    mkdir "OUTPUT";
#You are free to choose more options for Lima's run
if (defined ($ARGV[1])){
    print my $demultiplex=$path."/lima --ccs --same --min-passes 1 --single-side --split-bam-named ".$fastq_file." ".$barcodes_file." OUTPUT/".$data."_demux.fastq";
    print "\n\nBe patient please, lima is working!\n";
    system $demultiplex;
    opendir (IN, "OUTPUT");
my @dir = readdir(IN);
    closedir (IN);
    chdir "OUTPUT";
#For every fastq output file, we need to add the Barcode's name to the headers
my $subject_direction = "Edit";
     print "\n**********************\nContent of folder OUTPUT\n***************\n";
     opendir DIR, "/YOUR/PATH/TO/OUTPUT" or die "cannot read directory\n";
while (my $exis_file = readdir DIR) {
if ($exis_file =~ /_demux.(BC\d+--BC\d+).fastq/) {
my $barcode = $1;
my $edit_file = $exis_file;
   $edit_file =~ s/\.fastq/_new.fastq/;
     warn "editing $exis_file with barcode $barcode in $edit_file\n";
     open (my $in, "<", $exis_file) or die "cannot read $exis_file\n";
     open (my $out, ">", $edit_file) or die "cannot write $edit_file\n";
while (<$in>) {
               s/^@\m\d+/\@Barcode$barcode\_/;
     print $out $_;
        }
     close $in;
     close $out;
    }
}
     closedir DIR;
#New fastq files must be concatenated to get the final fastq file
     open $final_out, '>', 'Final_demux_lima.fastq' or die "Final_demux_lima.fastq: $!";
for $lima_file (glob '*_new.fastq') {
     open $host_file, '<', $lima_file or die "$lima_file: $!";
while (<$host_file>) {
     print {$final_out} $_ unless 0 == $.;
      }
  }
     close $final_out or die $!;
}
#Start the clustering tool Vsearch with your preferable option
     opendir DIR, "/YOUR/PATH/TO/OUTPUT/" or die "cannot read directory\n";
while (my $out_file = readdir DIR) {
if ($out_file =~ /demux_lima.fastq/) {
      print "Processing $out_file now......\n";
my $Vsearch=$path."/vsearch --cluster_fast ".$out_file." --id 0.97 --centroids ".$out_file."_cluster97.fastq";
      print "Vsearch:\n",$Vsearch,"\n";
      system $Vsearch;
      print "Vsearch on $out_file ready....\nStarting Clustering....\n";

}
}
      closedir DIR;
      print "\n*************************\nOperation done successfully\n\n";
      print"\nHave a great day!\n";
