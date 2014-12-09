#!/usr/bin/perl
use strict;
use SGE;
use ProgramName;

my $name=ProgramName::get();
die "$name <tag>\n" unless @ARGV==1;
my ($tag)=@ARGV;

my $sge=new SGE;

while(1) {
  my $n=$sge->countJobs($tag);
  last unless $n>0;
}
