#!/usr/bin/perl  -w

#@author: Weilong Guo, 2009, guoweilong@gmail.com
#Usage: program_name <input_file> <output_file>
#Description: count the number of the same lines

#? I need to calculate the number of the same words
use strict;

open( INFILE, "<$ARGV[0]" ) || die "Opening  file: $! ";
open OUTFILE, $ARGV[1]?">$ARGV[1]":'>-';
#'>-' stands for the standard output

my(@words, %count, $word); # (optionally) declare our variables
chomp(@words = <INFILE>);
foreach $word (@words) {
	$count{$word} += 1; # or $count{$word} = $count{$word} + 1;
}
print OUTFILE "Content\tNumber\n";
foreach $word (sort keys %count) { # or keys %count (without sort)
	print OUTFILE "$word\t$count{$word}\n";
}

close( OUTFILE );
close( INFILE );

