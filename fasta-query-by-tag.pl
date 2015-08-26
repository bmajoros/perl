#!/usr/bin/perl
use strict;
use FastaReader;
use FastaWriter;
use ProgramName;

my $name=ProgramName::get();
die "
$name <in.fasta> <key> <value>

example: $name in.fasta patient HG0096 > HG0096.fasta
         where defline is: >XYZ8732 /species=human /patient=HG0096

" unless @ARGV==3;
my ($infile,$key,$value)=@ARGV;

my $writer=new FastaWriter;
my $reader=new FastaReader($infile);
while(1) {
  my ($def,$seq)=$reader->nextSequence();
  last unless $def;
  $def=~/^\s*>\s*\S+(.*)/ || die "Can't parse defline: $def";
  my $extra=$1;
  my @fields=split/\s+/,$extra;
  foreach my $field (@fields) {
    if($field=~/\/$key=$value/) {
      $writer->addToFasta($def,$seq,\*STDOUT);
    }
  }
}



