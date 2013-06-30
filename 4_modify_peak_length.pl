#!/usr/bin/perl  -w

#@author: Weilong Guo, 2009, guoweilong@gmail.com
#Usage: program_name <input_file> <number> <output_file>
#Description: modify the lengths of the reads, to make all
#	the reads have the length of the input <number>, for
#	"+", modify the end position; "-", modify the start position

use strict;

open( INFILE, "<$ARGV[0]" ) || die "Opening  file: $! ";
open( OUTFILE, ">$ARGV[2]" ) || die "Opening  file: $! ";

(my $length = $ARGV[1]) || die "please specify the length of the reads.\n";

while(<INFILE>){
	chomp(my $line=$_);
	my @section = split(/\t/,$line);
	if($line =~ /\-/){
		$section[1] = $section[2]-$length;
	}else{
		$section[2] = $section[1]+$length;#suppose default is "+"
	}
	#print @section, "\n";
	print OUTFILE join("\t",@section),"\n";
}
close( OUTFILE );
close( INFILE );

