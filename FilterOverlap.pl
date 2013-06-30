#!/usr/bin/env perl
# FilterOverlap.pl

use warnings;
use strict;
use Getopt::Long;

my $input = '';
my $help;
if ( !GetOptions( 'f:s'    => \$input,
                  'help|h!' => \$help )
                   || $input eq '' || $help ){
print <<END_USAGE;
	Usage:
		FilterOverlap.pl -f input.txt
		-f    input file, similar with refFlat format
	Author: Guo, Weilong;	2011-08-20;	guoweilong\@gmail.com	
	Discription:
		The input file should be sorted first!!! (sort -k1.3n -k 2n a.txt)
		Overlapped region are removed, leaving only the first one.
END_USAGE
      exit -1;
}

open ( INFILE, "<$input") || die ("Can't open file $input.\n");
my ($chr, $left, $right) = ("", 0, 0);
while ( <INFILE> ) {
	chomp;
	my @array = split /\t/;
	if ($chr ne $array[0]) {
		$left = $right = 0;
		$chr = $array[0];
	}
	if ( $array[1] > $right) {
		print ( join "\t",@array ) ; print "\n";
		$left = $array[1];
		$right = $array[2];
	}
}
close();

