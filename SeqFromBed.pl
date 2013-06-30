#!/usr/bin/perl -w
# A script to get genomic sequences
# input: A bed file
# output: fasta file
# Xiaowo, Wang
# 2008.10.12
# Modified by GUO Weilong @ 2010/12/26
use strict;

if(@ARGV != 5)
{
	print "USAGE:     Get_seq nibdir bed upext downext output\n";
      print "Example:   Get_seq.pl /data2/ShareData/UCSC/hg18/nib/ test.bed 0 0 output.txt\n";
	print "Last mofication: GUO Weilong on 2010/12/27\n";
      exit;
}
my ($nibdir,$fbed,$upext,$downext,$fasta) = @ARGV;

my $tmp = $fasta.".tmp";
#print "Cut sequence from Genome...\n\n";
open(IN,"$fbed") || die "Can't open file $fbed.\n";
open(OUT,">$fasta") || die "Can't create file $fasta.\n";
while(<IN>){
	chomp;
	my @line=split(/\s+/);
	my $strand="+";
	if(@line<6 or $line[5] eq "+"){
		$line[1]=$line[1]-$upext;
		$line[2]=$line[2]+$downext;
		$strand="+";
	}
	else{
            # For "nibFrag" is open on 3' end and close on 5' end
            # $line[1]=$line[1]-$downext;
            # $line[2]=$line[2]+$upext;
            $line[1]=$line[1]-$downext+1;
		$line[2]=$line[2]+$upext+1;
		$strand="-";
	}

	system("nibFrag $nibdir/$line[0].nib $line[1] $line[2] $strand $tmp");
	open(FAIN,"$tmp");
	my $seq="";
	while(<FAIN>){
		chomp;
		if(/>/){next;}
		$seq.=$_;
	}
	close(FAIN);
      #system("if [ -f nibfrag_tmp.fa ]; then rm nibfrag_tmp.fa; fi");
      #system("rm $tmp");
	print OUT ">$line[0]:$line[1]-$line[2]\n$seq\n";
}
system("rm $tmp");
close(IN);
close(OUT);

