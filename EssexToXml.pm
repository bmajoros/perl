package EssexToXml;
use strict;

######################################################################
#
# EssexToXml.pm bmajoros@duke.edu 2/5/2016
#
# A visitor class for traversing an Essex tree and emitting XML
#
# Attributes:
#
# Methods:
#   $visitor=new EssexToXml();
#   $visitor->enter($node); # called by $node->recurse()
#   $visitor->leave($node); # called by $node->recurse();
######################################################################


#---------------------------------------------------------------------
#                           PUBLIC METHODS
#---------------------------------------------------------------------
sub new
{
  my ($class)=@_;
  
  my $self={};
  bless $self,$class;

  return $self;
}
#---------------------------------------------------------------------
#   $visitor->enter($node); # called by $node->recurse()
sub enter
{
  my ($self,$node)=@_;
  if(!ref $node) { print "$node " }
  else { my $tag=$node->getTag(); print "<$tag>" }
}
#---------------------------------------------------------------------
#   $visitor->leave($node); # called by $node->recurse();
sub leave
{
  my ($self,$node)=@_;
  if(ref $node){ my $tag=$node->getTag(); print "</$tag>" }
}
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------

1;

