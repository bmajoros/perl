package EssexNode;
use strict;

######################################################################
#
# EssexNode.pm bmajoros@duke.edu 10/27/2008
#
# A node in a parse tree for a Essex file (Hierarchical Exchange Language).
# These parse trees are produced by the EssexParser.  Literals (such as
# numbers and strings---i.e., the actual data) are not allocated an
# EssexNode; an EssexNode represents a parenthesized expression only.
# You can test whether something is a EssexNode via isaNode(), below.
#
# Attributes:
#   tag : string
#   elements : array
# Methods:
#   $node=new EssexNode($tag,$elem1,$elem2,...);
#   $tag=$node->getTag();
#   $n=$node->numElements();
#   $elem=$node->getIthElem($i);
#   $elem=$node->findChild($tag);
#   $array=$node->findChildren($tag);
#   $array=$node->findDescendents($tag);# always returns an array
#   $elem=$node->findDescendent($tag); # returns node or undef
#   $bool=$node->hasDescendentOrDatum($tagOrDatum);
#   $n=$node->countDescendents($tag);
#   $bool=$node->hasDescendent($tag);
#   $string=$node->getAttribute($attributeTag);
#   $array=$node->getElements();
#   $bool=EssexNode::isaNode($datum);
#   $bool=$node->hasCompositeChildren;
#   $node->print($filehandle);
#   $node->recurse($visitor); # must have methods enter(node) and leave(node)
#   $array=$node->query($query); # e.g., "book/chapter/section/page>34"
#                                # operators: >,>=,<,<=,=,!=,~
#                                # "~" means "contains substring"
#                                # i.e., probe/sequence~CCTAGCAGT
######################################################################


#---------------------------------------------------------------------
#                           PUBLIC METHODS
#---------------------------------------------------------------------
sub new
{
  my $class=shift @_;
  my $self={};
  bless $self,$class;

  my $n=@_;
  if($n>0) {
    $self->{tag}=shift @_;
    if(@_>0) {
      my $elements=[];
      @$elements=@_;
      $self->{elements}=$elements;
    }
  }

  return $self;
}
#---------------------------------------------------------------------
#   $tag=$node->getTag();
sub getTag
  {
    my ($self)=@_;
    return $self->{tag};
  }
#---------------------------------------------------------------------
#   $n=$node->numElements();
sub numElements
  {
    my ($self)=@_;
    my $elements=$self->{elements};
    my $n=$elements ? @$elements : 0;
    return $n;
  }
#---------------------------------------------------------------------
#   $elem=$node->getIthElem($i);
sub getIthElem
  {
    my ($self,$i)=@_;
    my $elements=$self->{elements};
    return $elements->[$i];
  }
#---------------------------------------------------------------------
#   $array=$node->getElements();
sub getElements
  {
    my ($self)=@_;
    return $self->{elements};
  }
#---------------------------------------------------------------------
#   $bool=EssexNode::isaNode($datum);
sub isaNode
  {
    my ($x)=@_;
    #my $debug=ref($x) ; print "XXX $debug\n";
    return ref($x) eq "EssexNode";
  }
#---------------------------------------------------------------------
#   $elem=$node->findChild($tag);
sub findChild
  {
    my ($self,$tag)=@_;
    my $elements=$self->{elements};
    my $n=@$elements;
    for(my $i=0 ; $i<$n ; ++$i) {
      my $elem=$elements->[$i];
      if(EssexNode::isaNode($elem) && $elem->getTag() eq $tag) {
	return $elem;
      }
    }
    return undef;
  }
#---------------------------------------------------------------------
#   $array=$node->findChildren($tag);
sub findChildren
  {
    my ($self,$tag)=@_;
    my $results=[];
    my $elements=$self->{elements};
    my $n=@$elements;
    for(my $i=0 ; $i<$n ; ++$i) {
      my $elem=$elements->[$i];
      if(EssexNode::isaNode($elem) && $elem->getTag() eq $tag) {
	push @$results,$elem;
      }
    }
    return $results;
  }
#---------------------------------------------------------------------
#   $string=$node->getAttribute($attributeTag);
sub getAttribute
  {
    my ($self,$tag)=@_;
    my $elements=$self->{elements};
    my $n=@$elements;
    for(my $i=0 ; $i<$n ; ++$i) {
      my $elem=$elements->[$i];
      if(EssexNode::isaNode($elem) && $elem->getTag() eq $tag) {
	return $elem->getIthElem(0);
      }
    }
    return undef;
  }
#---------------------------------------------------------------------
#   $node->print($filehandle);
sub print
  {
    my ($self,$file)=@_;
    $self->printRecursive(0,$file);
  }
#---------------------------------------------------------------------
#   $bool=$node->hasDescendent($tag);
sub hasDescendent
{
  my ($self,$tag)=@_;
  my $children=$self->{elements};
  if($children) {
    foreach my $child (@$children) {
      if(EssexNode::isaNode($child)) {
	if($child->{tag} eq $tag || $child->hasDescendent($tag)) { return 1 }
      }
      if($child eq $tag) { return 1 }
    }
  }
  return 0;
}
#---------------------------------------------------------------------
#   $n=$node->countDescendents($tag);
sub countDescendents
{
  my ($self,$tag)=@_;
  my $array=$self->findDescendents($tag);
  my $n=@$array;
  return $n;
}
#---------------------------------------------------------------------
#   $array=$node->findDescendents($tag);
sub findDescendents
  {
    my ($self,$tag)=@_;
    my $array=[];
    $self->findDesc($tag,$array);
    return $array;
  }
#---------------------------------------------------------------------
#   $array=$node->query($query); # e.g., "book/chapter/section/page>34"
#                                # operators: >,>=,<,<=,=,!=,~
#                                # "~" means "contains substring"
sub query
  {
    my ($self,$query)=@_;
    my @fields=split/\//,$query;
    if(@fields<2) {die "Essex query must contain at least one '/'\n"}
    my $rootTag=shift @fields;
    my $lastTagIndex=@fields-1;
    my $lastTag=$fields[$lastTagIndex];
    $lastTag=~/(\S+)([><=!~]+)(\S+)/ || 
      die "Syntax error in Essex query near \"$lastTag\"\n";
    $fields[$lastTagIndex]=$lastTag=$1;
    my $operator=$2;
    my $testValue=$3;
    my $depth=@fields;
    my $candidates;
    if($self->getTag() eq $rootTag) { $candidates=[$self] }
    else { $candidates=$self->findDescendents($rootTag) }
    my $n=@$candidates;
    my $hits=[];
    for(my $i=0 ; $i<$n ; ++$i) {
      my $candidate=$candidates->[$i];
      my $attr=$candidate;
      for(my $j=0 ; $j<$depth ; ++$j) {
	$attr=$attr->findChild($fields[$j]);
	if(!defined($attr)) {return $hits}
      }
      if($attr->numElements()<1) {die "$lastTag has no value\n"}
      my $value=$attr->getIthElem(0);
      my $result;
      if($operator eq "~") {$result=($value=~/$testValue/)}
      else {
	my $test="$value$operator$testValue";
	$result=eval($test);
      }
      if($result) {push @$hits,$candidate}
    }
    return $hits;
  }
#---------------------------------------------------------------------
#   $node->recurse($visitor); # must have methods enter(node) and leave(node)
sub recurse
{
  my ($self,$visitor)=@_;
  $visitor->enter($self);
  my $elements=$self->{elements};
  my $n=@$elements;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $elem=$elements->[$i];
    $elem->recurse($visitor);
  }
  $visitor->leave($self);
}
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------
sub findDesc
{
  my ($self,$tag,$array)=@_;
  my $children=$self->{elements};
  foreach my $child (@$children) {
    if(EssexNode::isaNode($child)) {
      if($child->{tag} eq $tag) { push @$array,$child }
      else { $child->findDesc($tag,$array) }
    }
  }
}
#---------------------------------------------------------------------
# my $elem=$node->findDescendent("tag");
sub findDescendent
{
  my ($self,$tag)=@_;
  my $children=$self->{elements};
  foreach my $child (@$children) {
    if(EssexNode::isaNode($child))
      { if($child->{tag} eq $tag) { return $child } }
  foreach my $child (@$children) {
    if(EssexNode::isaNode($child))
      { my $desc=$child->findDescendent($tag); if($desc) {return $desc} }
  }
  return undef;
}
#---------------------------------------------------------------------
#   $bool=$node->hasDescendentOrDatum($tagOrDatum);
sub hasDescendentOrDatum
{
  my ($self,$tag)=@_;
  if($self->{tag} eq $tag) { return 1 }
  my $children=$self->{elements};
  foreach my $child (@$children) {
    if(EssexNode::isaNode($child)) {
      if($child->hasDescendentOrDatum($tag)) { return 1 }
    }
    else { # not a node
      if($child eq $tag) { return 1 }
    }
  }
  return 0;
}
#---------------------------------------------------------------------
sub hasCompositeChildren
{
  my ($self)=@_;
  my $children=$self->{elements};
  my $numChildren=$children ? @$children : 0;
  for(my $i=0 ; $i<$numChildren ; ++$i)
    { if(EssexNode::isaNode($children->[$i])) { return 1 } }
  return 0;
}
#---------------------------------------------------------------------
sub printRecursive
{
  my ($self,$depth,$file)=@_;
  my $tab='   'x$depth;
  my $tag=$self->{tag};
  print $file "$tab($tag";
  my $elements=$self->{elements};
  my $n=$elements ? @$elements : 0;
  if($self->hasCompositeChildren()) {
    for(my $i=0 ; $i<$n ; ++$i) {
      my $child=$elements->[$i];
      if(EssexNode::isaNode($child)) {
	print $file "\n";
	$child->printRecursive($depth+1,$file);
      }
      else {
	my $tab='   'x($depth+1);
	print $file "\n$tab$child";
      }
    }
  }
  else {
    for(my $i=0 ; $i<$n ; ++$i) {
      my $elem=$elements->[$i];
      print $file " $elem";
    }
  }
  print $file ")";
}
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------


1;

