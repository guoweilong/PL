#!/usr/bin/perl -w
#
########################################
#
# File Name:
#   refFlat2GTF.pl
# 
# Description:
#   Convert the refFlat data file to GTF data file.
# 
# Usage:
#   refFlat2GTF.pl refFlat.txt GTF.txt
# 
# Author:
#   Xi Wang, wang-xi05@mails.thu.edu.cn
# 
# Date:
#   Mon Dec 20 16:59:24 CST 2010
#
########################################

# refFlat
#NKX2-8  NM_014360       chr14   -       36118966        36121537        36119857        36121345        2       36118966,36121188,      36120420,36121537,
#GPR45   NM_007227       chr2    +       105224631       105226356       105224747       105225866       1       105224631,      105226356,
#NXPH2   NM_007226       chr2    -       139143197       139254281       139144961       139254281       2       139143197,139254230,    139145705,139254281
#
# GTF
#chr1    miRNA   exon    100519385       100519452       .       +       .        gene_id "ENSG00000207750"; transcript_id "ENST00000385017"; exon_number "1"; gene_name "hsa-mir-553"; transcript_name "hsa-mir-553"; tss_id "TSS268"; 
#chr1    miRNA   exon    100616826       100616919       .       -       .        gene_id "ENSG00000216067"; transcript_id "ENST00000401248"; exon_number "1"; gene_name "AC104457.2-2"; transcript_name "AC104457.2-201"; tss_id "TSS269"; 
#chr1    miRNA   exon    107914984       107915075       .       -       .        gene_id "ENSG00000211552"; transcript_id "ENST00000390218"; exon_number "1"; gene_name "AC114491.1"; transcript_name "AC114491.1-201"; tss_id "TSS270"; 
#

use strict;
my $usage = "$0 <RefFlat_file> <GTF_file>\n";
my $infile = shift || die $usage;
my $outfile = shift || die $usage;


my ($chr, $source, $class, $start, $end, $score, $strand, $frame, $gene_id, $trans_id, $exon_no, $gene_name, $trans_name, $tss_id);
my ($no);
my (@starts, @ends);
my %transNo;
#my %gene_tss;
my %tss_group;
my $tss_no = 0;
my $tss_str;

open(IN, $infile) || die "Can't open $infile for reading!\n";
while(<IN>)
{
  chomp;
  my @a = split;
  if ($a[3] eq '+') 
  {
    $tss_str = "$a[2]_$a[3]_$a[4]";
  }
  else
  {
    $tss_str = "$a[2]_$a[3]_$a[5]";
  }
  next if (exists $tss_group{$tss_str});
  $tss_no ++;
  $tss_group{$tss_str} = "TSS".$tss_no; 
}
close IN;


open(IN, $infile) || die "Can't open $infile for reading!\n";
open(OUT, ">$outfile") || die "Can't open $outfile for writing!\n";
while(<IN>)
{
  chomp;
  my @a = split;
  $gene_id = $gene_name = $a[0];

  if(! exists $transNo{$a[1]})
  {
    $transNo{$a[1]} = 0;
    $trans_id = $trans_name = $a[1];
  }
  else 
  {
    $transNo{$a[1]} ++;
    $trans_id = $trans_name = $a[1]."_dup$transNo{$a[1]}";
  }

  #if (! exists $gene_tss{$gene_id})
  #{
  #  $tss_no ++;
  #  $tss_id = "TSS".$tss_no;
  #  $gene_tss{$gene_id} = $tss_id;
  #}
  #else 
  #{
  #  $tss_id = $gene_tss{$gene_id};
  #}
  
  $chr = $a[2];
  $strand = $a[3];
  $no = $a[8];
  @starts = split ",",$a[9];
  @ends = split ",",$a[10];

  $source = "gene";
  $class = "exon";
  $score = ".";
  $frame = ".";

  if ($strand eq '+')
  {
    $tss_str = "$a[2]_$a[3]_$a[4]";
  }
  else
  {
    $tss_str = "$a[2]_$a[3]_$a[5]";
  }
  $tss_id = $tss_group{$tss_str};
  for(my $i=0; $i<$no; $i++)
  {
    if($strand eq '+')
    {
      $exon_no = $i + 1;
    }
    else
    {
      $exon_no = $no - $i;
    }

    $start = $starts[$i] + 1;
    $end = $ends[$i];

    print OUT "$chr\t$source\t$class\t$start\t$end\t$score\t$strand\t$frame\t";
    print OUT "gene_id \"$gene_id\"; transcript_id \"$trans_id\"; exon_number \"$exon_no\"; gene_name \"$gene_name\"; transcript_name \"$trans_name\"; ";
    print OUT "tss_id \"$tss_id\"; ";
    print OUT "\n";
  }

}

close IN;
close OUT;
