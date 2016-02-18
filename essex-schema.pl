#!/usr/bin/perl
use strict;
use EssexParser;
use ProgramName;

my $name=ProgramName::get();
die "$name <in.essex>\n" unless @ARGV==1;
my ($infile)=@ARGV;

my (%schema,%order);
my $nextID=1;
my $parser=new EssexParser($infile);
while(1) {
  my $root=$parser->nextElem();
  last unless $root;
  if(EssexNode::isaNode($root)) { recurse($root) }
}

my @keys=keys %schema;
@keys=sort {$order{$a} <=> $order{$b}} @keys;
foreach my $key (@keys) {
  print "$key:\n";
  my @keys=keys %{$schema{$key}};
  foreach my $key (@keys) { print "\t$key\n" }
}

#============================================================
sub recurse {
  my ($node)=@_;
  my $tag=$node->getTag();
  if(!defined($order{$tag})) { $order{$tag}=$nextID++ }
  my $n=$node->numElements();
  for(my $i=0 ; $i<$n ; ++$i) {
    my $child=$node->getIthElem($i);
    if(EssexNode::isaNode($child)) {
      $schema{$tag}->{$child->getTag()}=1;
      recurse($child);
    }
  }
}


