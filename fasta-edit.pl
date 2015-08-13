#!/usr/bin/perl
use strict;
use FastaReader;
use FastaWriter;

die "
fasta-edit.pl <in.fasta> <op> <op> <op> ...
  where op is:
    I <pos> <seq> : insert sequence <seq> at position <pos>
    D <pos> <len> : delete <len> bases starting at position <pos>
    R <pos> <len> <seq> : replace <len> bases starting at
                          position <pos> with sequence <seq>
  All coordinates are zero-based
" unless @ARGV>2;
my $infile=shift @ARGV;

my $reader=new FastaReader($infile);
my ($defline,$sequence)=$reader->nextSequence();

while(@ARGV>0) {
  my $op=shift @ARGV;
  if($op eq "I") { # pos seq
    if(@ARGV<2) { die "operation \"I\" requires two parameters\n" }
    my $pos=shift @ARGV;
    my $seq=shift @ARGV;
    $pos=~/^\d+$/ || die "<pos> must be an integer\n";
    $seq=~/^[ACGTUNacgtun]+$/ || die "<seq> must be a sequence\n";
    substr($sequence,$pos,0)=$seq;
  }
  elsif($op eq "D") { # pos len
    if(@ARGV<2) { die "operation \"D\" requires two parameters\n" }
    my $pos=shift @ARGV;
    my $len=shift @ARGV;
    $pos=~/^\d+$/ || die "<pos> must be an integer\n";
    $len=~/^\d+$/ || die "<len> must be an integer\n";
    substr($sequence,$pos,$len)="";
  }
  elsif($op eq "R") { # pos len seq
    if(@ARGV<3) { die "operation \"R\" requires three parameters\n" }
    my $pos=shift @ARGV;
    my $len=shift @ARGV;
    my $seq=shift @ARGV;
    $pos=~/^\d+$/ || die "<pos> must be an integer\n";
    $len=~/^\d+$/ || die "<len> must be an integer\n";
    $seq=~/^[ACGTUNacgtun]+$/ || die "<seq> must be a sequence\n";
    substr($sequence,$pos,$len)=$seq;
  }
  else { die "Unknown op: $op" }
}

my $writer=new FastaWriter;
$writer->addToFasta($defline,$sequence,\*STDOUT);

