#!/usr/bin/perl  -w

#@author: Weilong Guo, 2009, guoweilong@gmail.com
#Usage: program_name <input_file> <output_file> <integer>
#Description: 

use strict;

open( INFILE, "<$ARGV[0]" ) || die "Opening  file: $! ";
open( OUTFILE, ">$ARGV[1]" ) || die "Opening  file: $! ";
my $n = $ARGV[2];
#ID
#BS  TGCCGGGAAG; chrX:100549779-100550579; 324; 10; ; p; 13.801
#BS  TTCCGGGAAA; chrX:101982786-101983586; 341; 10; 
my $count = 0; 
while(<INFILE>){
	chomp(my $line=$_);
	if($line =~ /^ID/){
		$count++;
	} 
	if($count==$n && $line =~/^BS/){
		my @section = split(/;/,$line);
		$section[1]   =~   s/^\s+//isg; # delete the first blank
		$section[6]   =~   s/^\s+//isg;
		print OUTFILE "$section[1]\t$section[6]\n";
	}
}
close( OUTFILE );
close( INFILE );



