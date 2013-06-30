#!/usr/bin/perl 

use strict;
use Getopt::Long;

# Get options from the commands
my $input = '';
my $exon = 'Exon.txt';
my $threeintron = 'ThreeIntron';
my $midintron = 'MidIntron';
my $fiveintron = 'FiveIntron';
my $help;

if ( !GetOptions( 'i:s' => \$input,
                  'E:s' => \$exon,
                  'T:s' => \$threeintron,
                  'M:s' => \$midintron,
                  'F:s' => \$fiveintron,
		  'help|h' => \$help )
                   || $input eq '' || $help ){
print <<END_USAGE;
Usage:	GetSixRegion.pl -i <input annotation> -E <exon> -T <3'Intron> -M <MidIntron> -F <5'Intron>
	-i		input file, similar with refFlat format
	[-ETMLR]	BED file to be output, 
Author: GUO Weilong, 2011-11-15, guoweilong\@gmail.com
Description:
    Input file: Standard refFlat file added with two columns in the front, format:
	ADSL  NM_000026   chr22 +     39072449    39080277    39072449    39080277    4   
	39072449,39075781,39079022,39080197,  39072661,39075985,39079067,39080277,
    Output file:
	Exon: BED file, output the exon regions
		chr22 39072561    39072761    +
		(Always the smaller number first)
	3'/5'Intron [5bp-125bp] away from splicing sites;
END_USAGE
      exit -1;
}

open (INFILE, "<$input") || die "Opening  file: $! ";
my ($chr, $strand);
open (EXON, ">$exon") || die ("Can't create file $exon\n");
open (TINTRON, ">$threeintron") || die ("Can't create file $threeintron\n");
open (FINTRON, ">$fiveintron") || die ("Can't create file $fiveintron\n");
open (MINTRON, ">$midintron") || die ("Can't create file $midintron\n");

while (<INFILE>) {
	chomp(my $line=$_);
	my @section = split (/\t/, $line);
	#Get splicing sites
	my @leftends = split (/,/, $section[9]);
	my @rightends = split (/,/, $section[10]);
	$chr = $section[2];
	$strand = $section[3];

	# ==>==[    exon 0   ]==================:==================[    exon  1  ]=====>> + strand
	#                     [ 5'I ]      [Mid Intron]     [ 3'I ]

	my ($from, $to);
	my $i;
	for ($i = 0; $i < @leftends - 1; $i++ ) {
		if ( $leftends[$i+1] - $rightends[$i] >= 500 ) {
			# Exon
			$from = $leftends[$i];
			$to = $rightends[$i];
			print EXON "$chr\t$from\t$to\t$strand\n";  
			# Left intron
			$from = $rightends[$i] + 5;
			$to = $rightends[$i] + 125;
			if ( $strand eq '+' ) {
				print FINTRON "$chr\t$from\t$to\t$strand\n";  
			} else {
				print TINTRON "$chr\t$from\t$to\t$strand\n";  
			}
			# Middle intron
			my $mid = int(($rightends[$i] + $leftends[$i+1]) / 2);
			$from = $mid - 50;
			$to = $mid + 50;
			print MINTRON "$chr\t$from\t$to\t$strand\n";  
			# Right intron
			$from = $leftends[$i+1] - 125;
			$to = $leftends[$i+1] - 5;
			if ( $strand eq '+' ) {
				print TINTRON "$chr\t$from\t$to\t$strand\n";
			} else {
				print FINTRON "$chr\t$from\t$to\t$strand\n";
			}
		}  
	}
	$from = $leftends[$i];
	$to = $rightends[$i];
	print EXON "$chr\t$from\t$to\t$strand\n";  

}
close (INFILE);
close (EXON);
close (TINTRON);
close (FINTRON);
close (MINTRON);


