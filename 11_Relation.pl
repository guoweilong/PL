#!/usr/bin/perl  -w

#@author: Weilong Guo, 2009, guoweilong@gmail.com
#Usage: program_name <input_file1> <input_file2>  <output_file>
#Description: 

use strict;

open( INFILE1, "<$ARGV[0]" ) || die "Opening  file: $! ";
open( INFILE2, "<$ARGV[1]" ) || die "Opening  file: $! ";
open( OUTFILE, ">$ARGV[2]" ) || die "Opening  file: $! ";
#INFILE1: chrX:100549779-100550579	25.34 	# foldchange(for example) 
#INFILE2: chrX:100549779-100550579	13.801 	# motif consence
my ($a,$b);
while($a=<INFILE1> ){
	$b=<INFILE2>;
	my @s1 = split(/\t/,$a);
	my @s2 = split(/\t/,$b);
	#print "$a";
	chomp($s1[1]);chomp($s2[1]);
	print OUTFILE "$s1[0]\t$s2[0]\t$s1[1]\t$s2[1]\n";
}
close( OUTFILE );
close( INFILE1 );
close( INFILE2 );
