#!/usr/bin/perl  -w

use strict;
use Getopt::Std;

sub Usage() {
	print "Usage:\n\tgtfParse.pl -f input.gtf [-o output.txt]\n";
	print "Author:\n\tGUO Weilong, 2011-03-27, guoweilong\@gmail.com\n";
	print "Discription:\n\tRead in the .gtf file, output the exons with \n\tfrequency which are less than 1.0.\n";
}

####  Format of .gtf file  ####
# chr1	Cufflinks	transcript	665900	666003	1000	-	.	gene_id "CUFF.491"; transcript_id "CUFF.491.1"; FPKM "75.0190504609"; frac "1.000000"; conf_lo "57.696343"; conf_hi "92.341758"; cov "6.661290";
# chr1	Cufflinks	exon	665900	666003	1000	-	.	gene_id "CUFF.491"; transcript_id "CUFF.491.1"; exon_number "1"; FPKM "75.0190504609"; frac "1.000000"; conf_lo "57.696343"; conf_hi "92.341758"; cov "6.661290";
#

my %options=();
getopts("f:o:",\%options);

if ( $ARGV[0]) {
	print "Unprocessed by Getopt::Std:\n";
}

if ( ! defined $options{f} ) {
	&Usage;	exit 1;
}

open( INFILE, "$options{f}" ) || die "Opening  file: $! ";
open OUTFILE, (defined $options{o})?">$options{o}":'>-';

my ($chr, $type, $start, $end, $strand, $freq); 
my (@array, @values, %attr, $value);
while(<INFILE>){
	@array = split("\t");
	($chr, $type, $start, $end, $strand)=($array[0], $array[2], $array[3], $array[4], $array[6]);
	@values = split /;/, $array[8];
	foreach $value(@values) {
		$value =~ m/\b(.+) \"(.+)\"/;
		$attr{$1} = $2;
		if(  $type eq "exon" && $1 eq "frac" ) {
			if ( $attr{"frac"} < 0.999 ) {
				print OUTFILE "$chr\t$start\t$end\t$strand\t";
				print OUTFILE "$attr{\"frac\"}\n"; #print "\n";
			}
		}
	}
}

close( OUTFILE );
close( INFILE );

