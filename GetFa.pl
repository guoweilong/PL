#! /usr/bin/perl -w
#Author: Weilong GUO
# using functions from Likun WANG
use strict;
use POSIX;
if(@ARGV != 4){
    print "./test.pl bed.txt -3 4\n";
    exit;
}
my ($methfile,$start,$end,$output) = @ARGV;

my @genome;
my %chr2id;
prepareSeq("/data2/ShareData/UCSC/hg18/genome/hg18.fa");

print STDERR "$output\n";
open (BED,$methfile) || die "can not open $methfile file";
open (OUT,">$output")|| die "can not open output file" ;
my $tmp;
while($tmp=<BED>) {
      chomp($tmp);
	my @list = split /\t/,$tmp;
      #print "$list[0]\t$list[1]\t$list[2]\t$list[3]\t$list[4]\t$list[5]\n";
      #print @list,"\n";
	my $str = getSeq("chr".$list[0], $list[1]+$start, $list[1]+$end );
	if($list[2] eq "-"){
            $list[3] = uc(reverseComplement($str)); 
      } else {
            $list[3] = uc($str);
      }
	print OUT "$list[0]\t$list[1]\t$list[2]\t$list[3]\t$list[4]\t$list[5]\n";
}
close(OUT);
close(BED);


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

