#!/usr/bin/env perl
# GFMtoSite.pl

use warnings;
use strict;
use Getopt::Std;
sub Usage() {
	print "Author:	GUO Weilong,	2011-05-10, guoweilong\@gmail.com\n";
	print "Usage:	GFMtoSite.pl -f GenerateFromMap.txt [-o output.txt -i|-s|(-c 10)]\n";
	print "	-f	input file, generated from the mapped result of bisulphite data\n";
	print "	-o	output file (optimal)\n";
	print "	-i	informative sites switch, only informative sites ( have reads on \n";
	print "		the same side) are showed when the swithch are specified (optimal)\n";
	print "	-s	strong sites switch, only sites have reads mapped on both sides \n";
	print "		are showed when specified, incompatible with \"-i|-c\" (optimal)\n";
	print "	-c <n>	(optional) Confidential swith, only sites have no less than n\n";
	print "		covered on both sides are showed, imcompatible with \"-i|-s\"\n";
	print "Discription:\n";
	print "	Transfer the GeneratedFromMapping file of bisulfite sequencing\n";
	print "	into a site format\n";
	print "Input format: <GeneratedFromMapping.txt>\n";
	print "\tchr1	470	472	CCG	- 	472 g - T19\n";
	print "\tchr1	479	481	CTG	- 	481 g + G1 - T21,G2\n";
	print "Output format:\n";
	print "\t1	469	-	CG	17	19	1\n";
	print "\t1	471	-	CG	19	19	2\n";
}

###  Deal with the options ###

my %options=();
getopts("f:o:isc:",\%options);

my $state = "n"; # normal
my $cfd_depth = 0;
if ( $ARGV[0]) {
	print "Unprocessed by Getopt::Std:\n";
	&Usage; exit 1;
}

if ( ! defined $options{f} ) {
	&Usage;	exit 1;
}

if ( defined $options{i} ) {
	if ( defined $options{s} ) {
		print "Error:	Incompatible switch [-i] and [-s]\n\n";
		&Usage; exit 1;
	} elsif ( defined $options{c} ) {
		print "Error:	Incompatible switch [-i] and [-c]\n\n";
		&Usage; exit 1;
	}
	$state = "i";
} elsif ( defined $options{s} ) {
	$state = "s";
	if ( defined $options{c} ) {
		print "Error:	Incompatible switch [-s] and [-c]\n\n";
		&Usage; exit 1;
	}
} elsif ( defined $options{c} ) {
	$state = "c";
	$cfd_depth = $options{c};
#	print "$options{c}\n";
}

#print "cfd_depth	$cfd_depth\n";

### END of dealing with the options ###

open ( INFILE, "$options{f}" ) || die "Opening  file: $! ";
open OUTFILE, (defined $options{o})?">$options{o}":'>-';

if ( $state eq "c" ) {
	while(<INFILE>){
		chomp;
		my (@array); 
		@array = split("\t");
		
		my ($chr, $pattern, $strand, $info) = ($array[0], $array[3], $array[4], $array[5]);
		###	chromosome	###
		my $nchr;
		if ( $chr =~ m/chr(.*)/ ) {
			$nchr = $1;
		} else {
			print "Wrong chromosome\n";
			exit(1);
		}
		###	strand	###
		$strand =~ s/ //;
		###	pattern	###
		if ($pattern eq "CG" ) {
			$pattern = "CG";
		} elsif ($pattern =~ m/C[ACT]G/ ) {
			$pattern = "CHG";
		} else {
			$pattern = "CHH";
		}
		# $info = "481 g + G1 - T21,G2"
		my @values = split / /, $info;
		my ($pos, $nt, %map); 
		# %map = "+ G1 - T21,G2"
		%map = ();
		($pos, $nt, %map) = @values;
		# $map{"+"} = "+ G1"
		if ( exists $map{"+"} && exists $map{"-"} ) {
			my @plus = split /,/, $map{"+"};
			my @minus = split /,/, $map{"-"};
			my ($block, $base, @bases);
			my $pluscount = 0; my $minuscount = 0;
			foreach $block (@plus) {
				$block =~ /([ACGT])([0-9]*)/;
				$pluscount += $2;
			}
			foreach $block (@minus) {
				$block =~ /([ACGT])([0-9]*)/;
				$minuscount += $2;
			}
			if ( $pluscount >= $cfd_depth && $minuscount >= $cfd_depth ) {
			#	print "pluscount :	$pluscount\n";
			#	print "minuscount :	$minuscount\n";
				my @mystrand = split /,/, $map{$strand};
				my %bases;
				foreach $block ( @mystrand ) {
					$block =~ /([ACGT])([0-9]*)/;
					$bases{$1} = $2;
				}
				if ( !exists $bases{"C"}) { $bases{"C"} = 0; }
				if ( !exists $bases{"T"}) { $bases{"T"} = 0; }
				my $all = $bases{"C"} + $bases{"T"};
				my $methy = $bases{"C"};
				print OUTFILE "$nchr\t$pos\t$strand\t$pattern\t$methy\t$all\n";
			}
		}
	}
} else {
	while(<INFILE>){
		chomp;
		my (@array, $nchr, @values, $value, $key, %bases, $base); 
		@array = split("\t");
		
		my ($chr, $pattern, $strand, $info);
		# $info = "481 g + G1 - T21,G2"
		
		($chr, $pattern, $strand, $info)=($array[0], $array[3], $array[4], $array[5]);
		###	chromosome	###
		if ( $chr =~ m/chr(.*)/ ) {
			$nchr = $1;
		} else {
			print "Wrong chromosome\n";
			exit(1);
		}
		###	strand	###
		$strand =~ s/ //;
		###	pattern	###
		if ($pattern eq "CG" ) {
			$pattern = "CG";
		} elsif ($pattern =~ m/C[ACT]G/ ) {
			$pattern = "CHG";
		} else {
			$pattern = "CHH";
		}
		
		@values = split / /, $info;
		my ($pos, $nt, %map); 
		# %map = "+ G1 - T21,G2"
		%map = ();
		($pos, $nt, %map) = @values;
		
		%bases = (); # initialization
		if ( exists $map{$strand} ) {
			@values = split /,/, $map{$strand};
		} else {
			@values = split /,/, "";
		}
		
		foreach $value ( @values ) {
			$value =~ /([ACGT])([0-9]*)/;
			$bases{$1} = $2;
		}
		if ( !exists $bases{"C"}) { $bases{"C"} = 0; }
		if ( !exists $bases{"T"}) { $bases{"T"} = 0; }

		my $all = $bases{"C"} + $bases{"T"};
		my $methy = $bases{"C"};
		if ( $state eq "n" ) {
			print OUTFILE "$nchr\t$pos\t$strand\t$pattern\t$methy\t$all\n";
		} elsif ( $state eq "i" ) {
			if ( $all > 0 ) {
				print OUTFILE "$nchr\t$pos\t$strand\t$pattern\t$methy\t$all\n";
			}
		} elsif ( $state eq "s" ) {
			if ( exists $map{"+"} && exists $map{"-"}  ) {
				print OUTFILE "$nchr\t$pos\t$strand\t$pattern\t$methy\t$all\n";
			}
		} else {
			print "Here's an error.\n";
		}
	}

}
close( OUTFILE );
close( INFILE );
