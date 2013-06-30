#!/usr/bin/perl 

#Author: GUO Weilong, 
#guoweilong@gmail.com 

use strict;

# Get options from the commands
if (@ARGV != 2) {
print <<END_USAGE;
Usage:       Antisense.pl input.fa output.fa
Author:      GUO Weilong    Version:    2011-06-11
Discription: To get the antisense sequences of the sequences 
    in the input.fa. The length of each line in output is fixed
    as 50 characters.
Example:     input.fa:  ACCGTTCCTTG
             output.fa: CAAGGAACGGT
END_USAGE
      exit -1;
}

open (INFILE, "<$ARGV[0]") || die "Opening  file: $! ";
open (OUTFILE, ">$ARGV[1]") || die "Cant't create file: $!";

my $longseq = "";
my $len = 50;
while (<INFILE>) {
      chomp(my $line=$_);
      if($line =~ /^>/) {
            $longseq =~ tr/[a,c,g,t,A,C,G,T]/[t,g,c,a,T,G,C,A]/;  
            $longseq = reverse(split(//,$longseq),""); # in case the $longseq is empty, "" is used but not $_
            for (my $pos =0; $pos < length($longseq); $pos += $len) {
                print OUTFILE substr($longseq, $pos, $len); print OUTFILE "\n";
            }
            $longseq = "";
            print OUTFILE "$line\n";
      } else {
            $longseq .= $line;
      }
}
$longseq =~ tr/[a,c,g,t,A,C,G,T]/[t,g,c,a,T,G,C,A]/;
for (my $pos=0; $pos < length($longseq); $pos += $len ) {
    print OUTFILE substr($longseq, $pos, $len); print OUTFILE "\n";
}

close (INFILE);
close (OUTFILE);

