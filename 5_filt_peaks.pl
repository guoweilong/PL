#!/usr/bin/perl  -w

#@author: Weilong Guo, 2009, guoweilong@gmail.com
#Usage: program_name <input_file> <number> <output_file>
#Description: filt the sequences with peaks number more than specified by <number>

use strict;

open( INFILE, "<$ARGV[0]" ) || die "Opening  file: $! ";
open( OUTFILE, ">$ARGV[3]" ) || die "Opening  file: $! ";

(my $fold = $ARGV[1]) || die "please specify the folds.\n";
(my $FDR = $ARGV[2]) || die "please specify the FDR.\n";
<INFILE>;
while(<INFILE>){
	chomp(my $line=$_);
	if($line !~/^#/){
		my @section = split(/\t/,$line);
		if(scalar(@section)>=9 && $section[7]=~/[0-9]/ && $section[8]=~/[0-9]/)
		{
			#print "$section[7],$section[8]\n";
			if( $section[7]>=$fold && $section[8]<=$FDR){
				print OUTFILE join("\t",@section),"\n";
			}
		}
	}
}
close( OUTFILE );
close( INFILE );



