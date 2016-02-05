#!/usr/bin/perl
use strict;
use ProgramName;
use EssexParser;
use EssexToXml;

my $name=ProgramName::get();
die "$name <in.sx>\n" unless @ARGV>=1;
my ($infile)=@ARGV;

my $visitor=new EssexToXml;
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  $root->recurse($visitor);
  print "\n";
}
