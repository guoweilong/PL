#!/usr/bin/perl  -w

use strict;
use Getopt::Std;

sub Usage() {
	print "Usage:\n\tMergeSites.pl -f sites.txt [-o output.txt]\n";
	print "Author:\n\tGUO Weilong, 2011-03-27, guoweilong\@gmail.com\n";
	print "Discription:\n\tMerge the fourth line for the same sites.\n";
}

####  Input file format  ####
#chr1	873846	-	0.212432
#chr1	888585	+	0.677433
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

my ($chr, $pos, $strand, $freq); 
my ( %sites, $site);
while(<INFILE>){
	chomp();
	($chr, $pos, $strand, $freq) = split("\t");
	$site = "$chr\t$pos\t$strand";
	if (exists $sites{$site} ) {
		$sites{$site} += $freq;
	} else {
		$sites{$site} = $freq;
	}
}

foreach $site ( sort keys %sites ) {
	$freq = $sites{$site};
	print OUTFILE "$site\t$freq\n";
}

close( OUTFILE );
close( INFILE );

