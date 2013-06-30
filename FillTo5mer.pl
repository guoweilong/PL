#! /usr/bin/env perl
use strict;
use Getopt::Long;

my $input = '';
my $output = 'output.txt';
my $fasta = '/data2/ShareData/UCSC/hg18/genome/hg18.fa"';
my $help;
if ( !GetOptions( 'i:s' => \$input,
	'f:s' => \$fasta,
	'o:s' => \$output,
	'help|h!' => \$help) ||
	$input eq '' || $help ) {
print <<END_USAGE;
Usage:
	FillTo5mer.pl -i <input file> -f <fasta> -o <output> 
	-i          input file, 
	-n          fasta file of the genome,
	-o          output file.
Author: GUO Weilong, 2011-08-29, guoweilong\@gmail.com
Description:
	Input file: 
	10      50515   -       CG      9       11
	10      54774   -       CG      23      25
	Output file:
	10      50515   -       TACGT   9       11
	10      54774   -       TACGA   23      25
END_USAGE
 	exit -1;
}

open(IN,"$input") || die "Can't open file $input.\n";
open(OUT,">$output") || die "Can't create file $output.\n";

my @genome;
my %chr2id;
prepareSeq($fasta);

print STDERR "$output\n";
while ( <IN> ) {
	chomp;
	my @line=split(/\s+/);
	my ($start, $end);
	if($line[2] eq "+"){
		$start=$line[1]-2;
		$end=$line[1]+3;
	} else {
		$start=$line[1]-2;
		$end=$line[1]+3;
	}

	my $str = getSeq("chr".$line[0], $start, $end );
	if($line[2] eq "-"){
		$line[3] = uc(reverseComplement($str)); 
	} else {
		$line[3] = uc($str);
	}
	print OUT join "\t", @line; print OUT "\n";
}
close(OUT);
close(IN);


###############
sub prepareSeq{
    print STDERR "reading genome file ...\n";
    my ($genome_file)=@_;
    open(GE, "$genome_file") || die "can not open $genome_file\n";
    my $chr = "";
    my $seq = "";
    while(<GE>){
	chomp();
	if($_ =~ /^>\s*(\S*)/){
	    if($chr ne ""){
		my $chr_id = @genome;
		$chr2id{$chr} = $chr_id;
		push @genome, $seq;
	    }
	    $chr = $1;
	    $seq = "";
	}else{
	    $seq .= $_;
	}
    }
    if($chr ne ""){
        my $chr_id = @genome;
        $chr2id{$chr} = $chr_id;
        push @genome, $seq;
    }
    print STDERR "reading genome file done\n";
}

sub getSeq{
    my ($chr, $start, $end)=@_;
    if(($start== -1)||($end == -1)){
        return "";
    }
    if(($chr eq "")||($start eq "")||($end eq "")){
        return "";
    }
    my $seq= substr($genome[$chr2id{$chr}], $start, $end-$start);
    if(!defined($seq)){
        die "$chr\:$start\-$end\n";
    }
    return $seq;
}

sub reverseComplement{
    my ($seq) = @_;
    my $revcom = reverse $seq;
    $revcom =~ tr/ACGTacgt/TGCAtgca/;
    return $revcom;
}

sub str_len{
    my ($seq)=@_;
    my $len = rindex $seq."\$", "\$";
    return $len;
}

