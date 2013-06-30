#!/usr/bin/perl  -w

#@author: Weilong Guo, 2009, guoweilong@gmail.com
#Usage: program_name <input_file> <output_file>
#Description: change the BED file to the seqList format: chrX:1-100
use strict;

open( INFILE, "<$ARGV[0]" ) || die "Opening  file: $! ";
open OUTFILE, $ARGV[1]?">$ARGV[1]":'>-';

my ($chrom, $chromStart, $chromEnd); 
while(<INFILE>){
	($chrom, $chromStart, $chromEnd)= /^([a-zA-Z]*)\t(\d*)\t(\d*)(\t)/;
	if($chromEnd){
		print OUTFILE "$chrom:$chromStart-$chromEnd\n";
	}
}

close( OUTFILE );
close( INFILE );


