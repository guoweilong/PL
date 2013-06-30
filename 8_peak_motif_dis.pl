#!/usr/bin/perl  -w

#@author: Weilong Guo, 2009, guoweilong@gmail.com
#Usage: program_name <input_file> <output_file>
#Description: 

use strict;

open( INFILE, "<$ARGV[0]" ) || die "Opening  file: $! ";
open( OUTFILE, ">$ARGV[1]" ) || die "Opening  file: $! ";

my ($chr, $start,$end);
my @section={0,0,0,0,0,0};
my ($motif, $oldmotif, $peak);
#ID  NTKCHVGGAA
#BS  ATTCAGTGAA; chrX:37168346-37168646; 14; 10; ; p; 3.88967
my $count = 0; my $n=0; 
while(<INFILE>){
	chomp(my $line=$_);
	if($line =~ /^ID/){
		@section =split(' ',$line);
		$n=0;
		$motif = $section[1];
		if($count==0){
			$count++;	
			print OUTFILE "#$count\n";
			print OUTFILE "motif$count<-c(";
		}else{
			print OUTFILE ");\nhist( motif$count,c(-20:20)*20);\nmean(motif$count);var(motif$count);\n";
			$count++;	
			print OUTFILE "#$count\n";
			print OUTFILE "motif$count<-c(";
		}
	} 
	if ($line =~ /^BS/) {
		$n++;
		chomp($line);
		@section = split(';',$line);
		(undef,$start,$end) = split(/:|-/,$section[1]);
#		print "$start,$end\n";
		($peak,undef) = split(/;/,$section[2]);
#		print "$peak\n";
		($motif,undef) = split(/;/,$section[3]);
		my $dis = ($start-$end)/2+$section[2]+$section[3]/2;
		if($n==1){
			print OUTFILE "$dis";
		}else{
			print OUTFILE ",$dis";
		}
	}
}
print OUTFILE ");\nhist( motif$count,c(-20:20)*20);\nmean(motif$count);var(motif$count);\n";
close( OUTFILE );
close( INFILE );



