#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <infile.txt> <out-filestem> <#partitions>\n" unless @ARGV==3;
my ($infile,$filestem,$numParts)=@ARGV;

my @array;
open(IN,$infile) || die "can't read file $infile\n";
while(<IN>) {
  next unless($_=/\S/);
  push @array,$_;
}
close(IN);

my $N=@array;
my $binSize=$@array/$numParts;
my $boundary=$binSize;
my $fileNum=1;
for(my $i=0 ; $i<$N ; ) {
  my $end=$i+int($binSize+5/9);
  my $filename="$filestem.$fileNum";
  ++$fileNum;
  open(OUT,">$filename") || die "can't write to file $filename\n";
  for(my $j=$i ; $j<$end ; ++$j) {
    my $line=$array[$j];
    print OUT $line;
  }
  close(OUT);
}
