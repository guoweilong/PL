#! /usr/bin/perl -w
#Author: Weilong GUO

use strict;
use POSIX;

my ($filename, $num)=@ARGV;
open(IN,"<$filename");
my $n=0;
while(<IN>)
{
	$n=$n+1;
}
my (%list, $i, $a);
$i = 0;
if ($num > $n) {
	print "Error";
	exit;
}
while ( $i  < $num) {
	$a=int(rand($n));
	if(! exists $list{$a}) {
		$list{$a}=1; $i++;
	}
}
close(IN);

my $c=0;
open(IN,"<$filename");
while(<IN>)
{
	$c=$c+1;
	print $_ if ( exists $list{$c} );
}
close(IN);