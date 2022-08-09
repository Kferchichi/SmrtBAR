# Smarty

Is a Package to analyse mixture of barcoded-DNA data.
Please take in consideration some depencies and also that depending on your sequencing machine, there are two ways to analyse the data.
The package contains three perl scripts that use some PacBio tools and other alignment Algorithms.

How it works:

1-Smarty.pl sums up the work of two Pacific Biosciences tools that are Lima (Barcodes Demultiplexer
that allows the analysis of multiplexed samples) and Laa (Long Amplicon
analysis to generate highly accurate, phased and full-length consensus sequences for multiple genes
in a single sequencing run).
As an input, Smarty.pl needs a SUBREADSET.XML file which provides all sequencing information; then
a text file in fasta format with all used barcodes and their sequences and an
ADAPTERSET_PLATEPOOL.FASTA in cases where the samples have been pooled and sequenced
on the same SMRT cell.
After recognizing the input files, the program sorts them and calls Lima to proceed the work.
In addition, Lima needs multiplexed BAM files, belonging to the run folder output of the sequencing, to
produce a demultiplexed BAM file which will be used as input in the Laa analysis
2-SmartyHIFI.pl
3-Barcode_trans.pl
Barcode_trans.pl comes as a next step in case we need to get sequences with the associated
primers and in the appropriate regions; this program requires, as mentioned above, three input files:
*List of used primers (name, sequences, F/R...etc.) in csv format.
*Translation table (Barcodes and related region names) in txt format.
*Amplicon.analysis.fastq file which has been produced, in a previous step, by the laa analysis.
Starting with recognition of the input files, the program can check your data and reports the
encountered problems in case your files do not meet the required formats or also if you forgot
something else in your input files or in your script.
When all data exist, the first step is to open and prepare a converted fasta file and a junk file without
filling them.
The primers will be sorted towards names, sequences and direction and you will get a list with all used
primers, only their names, and then just part of the whole sequence will be compared with each primer
sequence one by one. This task is performed by the NeedlemanWunsch Algorithm and using a precise
number of bases from the primer sequences as a score to confirm whether there is compatibility or not.
After the alignment has been done, the fasta file and its corresponding junk file will be filled and for
every used primer there will be a fasta file with all found sequences meeting the minimal scoring
requirements.

Dependencies:

gcc
htslib
pbcopper
zlib
-Algorithm-NeedlemanWunsch
-perl
