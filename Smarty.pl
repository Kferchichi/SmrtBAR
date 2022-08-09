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
#Smarty.pl                                                                                         #
#                                                                                                  #
#Programm created to analyse(demultiplex) multiplexed SMRT data                                    #
#                                                                                                  #
#                                                                                                  #                                                                                               #
# Release date: October 2019                                                                       #
#                                                                                                  #
####################################################################################################


print "Smarty.pl by Khaoula Ferchichi\nEnjoy it!\n";


my ($xml_file, $barcodes_file, $adapterset_platepools);

#number of arguments varies between 2 and 3 depending on how the samples have been sequenced
if(@ARGV){
    $xml_file=$ARGV[0];
    print "Xml file is: $xml_file\n";
    $barcodes_file=$ARGV[1];
    print "Barcodes are: $barcodes_file\n";
	if (defined($ARGV[2])) {
   $adapterset_platepools=$ARGV[2];
    print "Samples have been pooled and sequenced on different SMRT cells\n";
	print "Adapter's information are in: $adapterset_platepools\n"; 
   }
else  {
   $adapterset_platepools="";
   print "Samples have been pooled and sequenced on the same SMRT cell\n";
   print "No need to adapter's information\n";
   
   }

	} 
	
	
else {
    print "\nUsage: perl Smarty.pl [name].subreadset.xml [PacBio_barcodes].fasta [adapterset_platepools].fasta\t try again\n";
    die;
	}
	
my $data = $xml_file;
$data =~ s/\.subreadset\.xml//i;
	
#please note that you need to write your own path where you package has been saved.
my $path = '/home/nees/Package_SMRT_DEMUX-v0.1/tools';                    #Path to lima and laa shell scripts 


print cwd,"\n\n";
#Create an OUTPUT subdirectory
    print "Creating an OUTPUT file \n";
    rmtree('OUTPUT');

mkdir "OUTPUT";
#If there are adapters, Lima will need the adapter's file and all info/parameters used to sequence the data
#Please note that you can add more options to the run of lima
if (defined ($ARGV[2])){
    print my $demultiplex=$path."/lima --ccs --single-side --split-bam-named ".$xml_file." ".$adapterset_platepools." OUTPUT/".$data."_demultiplex.bam";
    print "\n\nBe patient please, lima is working!\n";

    system $demultiplex;
}else{
    my @files=glob("*.*");
    for my $item(@files){
        copy($item,"OUTPUT") or die "$1";
    }
}
opendir (IN, "OUTPUT");
my @dir = readdir(IN);
closedir (IN);
chdir "OUTPUT";
#Lon amplicon analysis starts using the demultiplexed bam files of lima and the barcode's info
my $subject_direction = "CCS_LAA";
print "\n**********************\nContent of folder OUTPUT\n***************\n";
foreach(@dir){
    if(/subreadset.xml{1}\b/){

        print "Processing $_ now......\n";
        my $Lima="$path/lima --ccs --same --min-passes 1 ".$_." ../".$barcodes_file." ".$_."ccs.bam";
        print "Lima:\n",$Lima,"\n";
        system $Lima;
        print "CCS on $_ ready....\nStarting LAA....\n";
       
	   my $LAA="$path/laa -v --minLength 300 --ChimeraFilter --chimeraScoreThreshold=2 --logFile=errors.txt --resultFile=".$_.".Amplicon_analysis.fastq --junkFile=".$_.".Junk.fastq --reportFile=$_.Report.csv --inputReportFile=$_.Quality_report.csv --subreadsReportPrefix=$_.Subread_report_prefix.csv ".$_."ccs.subreadset.xml";

        print "Long Amplicon Analysis:\n",$LAA,"\n";
        system $LAA;
        
		print "\nLAA is done!\n";
        print "\n*************************\nnext Tag\n\n";
        
    }
}


print "\n*************************\nOperation done successfully\n\n";
print"\nHave a great day!\n";

