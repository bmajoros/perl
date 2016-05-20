#!/usr/bin/perl
use strict;
use ProgramName;

my $name=ProgramName::get();
die "$name <jobID>\n" unless @ARGV==1;
my ($jobID)=@ARGV;

open(IN,"sacct -j $jobID -l -p |") || die;
my $header=<IN>; my $underlines=<IN>; my $data=<IN>;
chomp $header; chomp $data;
my @header=split/\|/,$header; my @data=split/\|/,$data;
my $n=@header;
print "$n attributes\n";
for(my $i=0 ; $i<$n; ++$i) {
  my $key=$header[$i];
  my $value=$data[$i];
  my $L=length($key);
  for(my $i=$L ; $i<20 ; ++$i) { $key.=" " }
  print "$key   $value\n";
}
close(IN);

