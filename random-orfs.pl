#!/usr/bin/env perl
use strict;
use FastaReader;

die "$0 <chromosome.fasta> <TGA,TAG,TAA> <num-orfs>\n" unless @ARGV==3;
my ($filename,$stops,$NUM_ORFS)=@ARGV;

my @stops=split/,/,$stops;
my %stops;
foreach my $stop (@stops) { $stops{$stop}=1 }

sub sample {
  my ($chr)=@_;
  my $L=length($$chr);
  my $pos=int(rand($L-100000));
  my $codon;
  while($pos<$L-3) {
    $codon=substr($$chr,$pos,3);
    if($codon eq "ATG") { last }
    $pos+=3;
  }
  if($codon ne "ATG") { return -1 }
  my $codons=0;
  while($pos<$L-3) {
    my $codon=substr($$chr,$pos,3);
    if(substr($codon,0,1) eq "N" || substr($codon,1,1) eq "N" || 
       substr($codon,2,1) eq "N") { return -1 }
    last if($stops{$codon});
    $codons+=1;
    $pos+=3;
  }
  return $codons;
}

#============================ main() ==============================
my $reader=new FastaReader($filename);
while(1) {
    my ($defline,$seq)=$reader->nextSequenceRef();
    last unless $defline;
    for(my $i=0 ; $i<$NUM_ORFS ; ++$i) {
      my $length=sample($seq);
      if($length<0) { next }
      print "$length\n";
    }
  }
$reader.close();



