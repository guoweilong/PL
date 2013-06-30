#!/usr/bin/perl 

#Description:
#     Input file: Standard refFlat file added with two columns in the front, format:
#     ADSL  NM_000026   chr22 +     39072449    39092521    39072508    39092472    13    39072449,39075781,39079022,39080197,39084813,39085209,39086351,39087222,39087437,39088930,39090225,39090829,39092385,   39072661,39075985,39079067,39080277,39084985,39085256,39086442,39087292,39087585,39089021,39090315,39091006,39092521,
#     Output file:
#     ExonToIntron : BED file, store the splicing site from exon region (left) to intro (right) with format
#           chr22 39072561    39072761    +
#           where, the '-' strand is reversed, that is first site is smaller than the second one
#     IntronToExon : BED file, storm the splicing site from intron region (left) to exon (right) with format same with the above


use strict;
use Getopt::Long;

# Get options from the commands
my $input = '';
my $etoi = 'ExonToIntron.txt';
my $itoe = 'IntronToExon.txt';
my $len = 100;
my $help;
if ( !GetOptions( 'f:s'    => \$input,
                  'E:s' => \$etoi,
                  'I:s' => \$itoe,
                  'L|l:s' => \$len,
                  'help|h!' => \$help )
                   || $input eq '' || $help ){
print <<END_USAGE;
Author: GUO, Weilong, 2011-11-15, guoweilong\@gmail.com
Usage:
    SSFromRefFlat.pl -f <refFlat> -E <donor> -I [acceptor] -l 100
    -f    input file, similar with refFlat format
    [-EI] BED file to be output, ExonToIntron (donor) / IntronToExon (acceptor)
    [-l]  length of the flank region, default: 100   
END_USAGE
      exit -1;
}

open (INFILE, "<$input") || die "Opening  file: $! ";
my ($chr, $strand);
open (E2I, ">$etoi") || die ("Can't create file $etoi;");
open (I2E, ">$itoe") || die ("Can't create file $itoe;");

while (<INFILE>) {
	chomp(my $line=$_);
	my @section = split (/\t/, $line);
	#Get splicing sites
	my @leftends = split (/,/, $section[9]);
	my @rightends = split (/,/, $section[10]);
	$chr = $section[2];
	$strand = $section[3];

	# ==>==[ 0 ]=====>===[ 1 ]======>===>> + strand
	#      ^:left ends      ^:right ends
	# <<==<==[ 0 ]=====<===[ 1 ]====<===== - strand
	#        ^:left ends      ^:right ends
	my ($from, $to);
	#if ($strand == "+") {  
	#if ($strand =~ /\+/) {
	if ($strand eq "+") {
		for (my $i = 0; $i < @leftends - 1; $i++ ) {
			$from = $rightends[$i] - $len;
			$to = $rightends[$i] + $len;
			print E2I "$chr\t$from\t$to\t$strand\n";  
			$from = $leftends[$i+1] - $len;
			$to = $leftends[$i+1] + $len;
			print I2E "$chr\t$from\t$to\t$strand\n";
		}
	} else {
		for (my $i = 0; $i < @leftends - 1; $i++ ) {
			$from = $rightends[$i] - $len;
			$to = $rightends[$i] + $len;
			print I2E "$chr\t$from\t$to\t$strand\n";
			$from = $leftends[$i+1] - $len;
			$to = $leftends[$i+1] + $len;
			print E2I "$chr\t$from\t$to\t$strand\n";
		}
	}
}
close (INFILE);
close (E2I);
close (I2E);



