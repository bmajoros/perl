#!/usr/bin/perl
use strict;
use FastaReader;
use FastaWriter;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.fasta> <#bases>\n" unless @ARGV==2;
my ($infile,$N)=@ARGV;

my $writer=new FastaWriter;
my $reader=new FastaReader($infile);
while($N>0) {
  my ($def,$seq)=$reader->nextSequence();
  last unless $def;
  my $L=length($seq);
  if($L>$N) { $seq=substr($seq,0,$N) }
  $N-=length($seq);
  $writer->addToFasta($def,$seq,\*STDOUT);
}

