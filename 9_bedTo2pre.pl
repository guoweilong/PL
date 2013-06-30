#!/usr/bin/perl  -w

#@author: Weilong Guo, 2009, guoweilong@gmail.com
#Usage: program_name <input_file> <number> <output_file_1> <output_file_2>
#Description: output two list files, which are for peaks and control, peaks' length is <number> 

use strict;

open( INFILE, "<$ARGV[0]" ) || die "Opening  file: $! ";
open( OUTFILE_1, ">$ARGV[2]" ) || die "Opening  file: $! ";
open( OUTFILE_2, ">$ARGV[3]" ) || die "Opening  file: $! ";

my ($chr, $start,$end, $col);
if($#ARGV>3){$col = $ARGV[4];}else{$col=0;}
#.xls format: 0chr 1start 2end 3length 4summit 5tags 6-10*log10(pvalue) 7fold-enrichment 8FDR%
my $length = $ARGV[1]/2;
while(<INFILE>){
	chomp(my $line=$_);
	if($line !~ /^#/){
		my @section = split(/\t/,$line);
		if($section[1]=~/[0-9]/&&$section[2]=~/[0-9]/&&$section[4]=~/[0-9]/)
		{
			$chr = $section[0];
			$start = $section[1]+$section[4]-$length; $end = $section[1]+$section[4]+$length;
			print OUTFILE_1 ($col==0)?"$chr:$start-$end\n":"$chr:$start-$end\t$section[$col]\n";
			$start = $section[1]+$section[4]-$length*4; $end = $section[1]+$section[4]-$length*2;
			print OUTFILE_2 ($col==0)?"$chr:$start-$end\n":"$chr:$start-$end\t$section[$col]\n";
		}
	}
}
close( OUTFILE_1 );
close( OUTFILE_2 );
close( INFILE );



