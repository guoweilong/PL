#!/usr/bin/perl  -w

#@author: Weilong Guo, 2009, guoweilong@gmail.com
#Usage: program_name <input_file> <output_file>
#Description: input_file is a BED file, output the length of each reads by row (one row, one number).  
use strict;

open( INFILE, "<$ARGV[0]" ) || die "Opening  file: $! ";
open OUTFILE, $ARGV[1]?">$ARGV[1]":'>-';
#'>-' stands for the standard output

while ( <INFILE> ) {
	my ($chrom, $chromStart, $chromEnd) = /^(.*)\t(\d*)\t(\d*)(\t)/;
	#print $chromStart ,">\t",$chromEnd,"<\n";
	my $out = $chromEnd - $chromStart;
	print OUTFILE $out,"\n";
}
close( OUTFILE );
close( INFILE );
