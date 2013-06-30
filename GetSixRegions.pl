#!/usr/bin/perl 


use strict;
use Getopt::Long;

# Get options from the commands
my $input = '';
my $exon = 'Exon.txt';
my $threeintron = 'ThreeIntron';
my $fiveintron = 'FiveIntron';
my $midintron = 'MidIntron';
my $leftintron = 'LeftInron';
my $rightintron = 'RightIntron';
my $help;

if ( !GetOptions( 'i:s' => \$input,
                  'E:s' => \$exon,
                  'T:s' => \$threeintron,
                  'M:s' => \$midintron,
                  'F:s' => \$fiveintron,
                  'L:s' => \$leftintron,
                  'R:s' => \$rightintron,
		  'help|h' => \$help )
                   || $input eq '' || $help ){
print <<END_USAGE;
      Usage:
            GetSixRegion.pl -i <input annotation> -E <exon> -T <3'Intron> -M <MidIntron> -F <5'Intron> -L <leftIntron> -R <rightIntron>
            -i		input file, similar with refFlat format
            [-ETMLR]	BED file to be output, 
Author: GUO Weilong, 2011-08-23, guoweilong\@gmail.com
Description:
	Input file: Standard refFlat file added with two columns in the front, format:
	79.7544   ADSL  NM_000026   chr22 +     39072449    39092521    39072508    39092472    13   
	39072449,39075781,39079022,39080197,39084813,39085209,39086351,39087222,39087437,39088930,39090225,39090829,39092385,  
	39072661,39075985,39079067,39080277,39084985,39085256,39086442,39087292,39087585,39089021,39090315,39091006,39092521,
	Output file:
	Exon: BED file, output the exon regions
		chr22 39072561    39072761    +
		(Always the smaller number first)
	3'/5'Intron [5bp-25bp] away from splicing sites;
	Left/Right intron [25bp-125bp] away from splicing sites
END_USAGE
      exit -1;
}

open (INFILE, "<$input") || die "Opening  file: $! ";
my ($chr, $strand);
open (EXON, ">$exon") || die ("Can't create file $exon\n");
open (TINTRON, ">$threeintron") || die ("Can't create file $threeintron\n");
open (FINTRON, ">$fiveintron") || die ("Can't create file $fiveintron\n");
open (LINTRON, ">$leftintron") || die ("Can't create file $leftintron\n");
open (RINTRON, ">$rightintron") || die ("Can't create file $rightintron\n");
open (MINTRON, ">$midintron") || die ("Can't create file $midintron\n");

while (<INFILE>) {
	chomp(my $line=$_);
	my @section = split (/\t/, $line);
	#Get splicing sites
	my @leftends = split (/,/, $section[10]);
	my @rightends = split (/,/, $section[11]);
	$chr = $section[3];
	$strand = $section[4];

	# ==>==[    exon 0     ]*****================>===============*****[    exon  1     ]========>> + strand
	#      ^:left ends [$i]                                           ^:left ends[$i+1]
	#                      ^:right ends [$i]                                            ^:right ends[$i+1]
	#                            [3'intron> mid-intron <5'intron]

	# <<==<==[   exon 0    ]=====<======[   exon 1    ]====<============ - strand
	#        ^:left ends [$i]          ^:left ends[$i+1]
	#                      ^:right ends [$i]          ^:right ends[$i+1]

	my ($from, $to);
	my $len = 25;
	if ($strand eq "+") {
		my $i;
		for ($i = 0; $i < @leftends - 1; $i++ ) {
			$from = $leftends[$i];
			$to = $rightends[$i];
			print EXON "$chr\t$from\t$to\t$strand\n";  

			$from = $rightends[$i] + 5;
			$to = $rightends[$i] + $len;
			print FINTRON "$chr\t$from\t$to\t$strand\n";  

			$from = $rightends[$i] + $len + 1;
			$to = $rightends[$i] + $len + 100;
			print LINTRON "$chr\t$from\t$to\t$strand\n";  

			$from = $rightends[$i] + $len + 101;
			$to = $leftends[$i+1] - $len - 101;
			print MINTRON "$chr\t$from\t$to\t$strand\n";  

			$from = $leftends[$i+1] - $len - 100;
			$to = $leftends[$i+1] - $len - 1;
			print RINTRON "$chr\t$from\t$to\t$strand\n";  

			$from = $leftends[$i+1] - $len;
			$to = $leftends[$i+1] - 5;
			print TINTRON "$chr\t$from\t$to\t$strand\n";  
		}
		$from = $leftends[$i];
		$to = $rightends[$i];
		print EXON "$chr\t$from\t$to\t$strand\n";  
	} else {
		my $i;
		for ( $i = 0; $i < @leftends - 1; $i++ ) {
			$from = $leftends[$i];
			$to = $rightends[$i];
			print EXON "$chr\t$from\t$to\t$strand\n";  

			$from = $leftends[$i+1] - $len;
			$to = $leftends[$i+1] - 5;
			print FINTRON "$chr\t$from\t$to\t$strand\n";  

			$from = $leftends[$i+1] - $len - 100;
			$to = $leftends[$i+1] - $len - 1;
			print LINTRON "$chr\t$from\t$to\t$strand\n";  

			$from = $rightends[$i] + $len + 101;
			$to = $leftends[$i+1] - $len -101;
			print MINTRON "$chr\t$from\t$to\t$strand\n";  

			$from = $rightends[$i] + $len + 1;
			$to = $rightends[$i] + $len + 100;
			print RINTRON "$chr\t$from\t$to\t$strand\n";  

			$from = $rightends[$i] + 5;
			$to = $rightends[$i] + $len;
			print TINTRON "$chr\t$from\t$to\t$strand\n";  
		}
		$from = $leftends[$i];
		$to = $rightends[$i];
		print EXON "$chr\t$from\t$to\t$strand\n";  
	}
}
close (INFILE);
close (EXON);
close (TINTRON);
close (FINTRON);
close (LINTRON);
close (RINTRON);
close (MINTRON);


