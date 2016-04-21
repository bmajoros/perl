package Gene;
use strict;

######################################################################
#
# Gene.pm bmajoros@tigr.org 4/29/2005
#
# Attributes:
#   transcripts : list of Transcript objects
#   ID
#   transcriptHash : transcripts hashed by their ID
# Methods:
#   $gene=new Gene();
#   $gene->addTranscript($t);
#   $n=$gene->getNumTranscripts();
#   $t=$gene->getIthTranscript($i);
#   $t=$gene->longestTranscript();
#   $id=$gene->getId();
#   $gene->setId($id);
#   $begin=$gene->getBegin(); # leftmost edge
#   $end=$gene->getEnd();     # rightmost edge
#   $strand=$gene->getStrand();
#   $substrate=$gene->getSubstrate();
#   $gff=$gene->toGff();
#   
######################################################################


#---------------------------------------------------------------------
#                           PUBLIC METHODS
#---------------------------------------------------------------------
#   $gene=new Gene();
sub new
{
  my ($class)=@_;

  my $transcripts=[];
  my $self=
    {
     transcripts=>$transcripts,
     transcriptHash=>{}
    };
  bless $self,$class;

  return $self;
}
#---------------------------------------------------------------------
#   $strand=$gene->getStrand();
sub getStrand
{
    my ($self)=@_;
    my $transcripts=$self->{transcripts};
    my $transcript=$transcripts->[0];
    return $transcript->getStrand();
}
#---------------------------------------------------------------------
#   $strand=$gene->getSubstrate();
sub getSubstrate
{
    my ($self)=@_;
    my $transcripts=$self->{transcripts};
    my $transcript=$transcripts->[0];
    return $transcript->getSubstrate();
}
#---------------------------------------------------------------------
#   $begin=$gene->getBegin(); # leftmost edge
sub getBegin
  {
    my ($self)=@_;
    my $transcripts=$self->{transcripts};
    my $n=@$transcripts;
    my $begin;
    for(my $i=0 ; $i<$n ; ++$i)
      {
	my $transcript=$transcripts->[$i];
	my $b=$transcript->getBegin();
	if(!defined($begin) || $b<$begin) {$begin=$b}
      }
    return $begin;
  }
#---------------------------------------------------------------------
#   $end=$gene->getEnd();
sub getEnd
  {
    my ($self)=@_;
    my $transcripts=$self->{transcripts};
    my $n=@$transcripts;
    my $end;
    for(my $i=0 ; $i<$n ; ++$i)
      {
	my $transcript=$transcripts->[$i];
	my $e=$transcript->getEnd();
	if(!defined($end) || $e>$end) {$end=$e}
      }
    return $end;
  }
#---------------------------------------------------------------------
#   $gene->addTranscript($t);
sub addTranscript
  {
    my ($self,$transcript)=@_;
    my $id=$transcript->getTranscriptId();
    my $hash=$self->{transcriptHash};
    if(defined($hash->{$id})) { return }
    push @{$self->{transcripts}},$transcript;
    $hash->{$id}=$ranscript;
  }
#---------------------------------------------------------------------
#   $n=$gene->getNumTranscripts();
sub getNumTranscripts
  {
    my ($self)=@_;
    my $transcripts=$self->{transcripts};
    return 0+@$transcripts;
  }
#---------------------------------------------------------------------
#   $t=$gene->getIthTranscript($i);
sub getIthTranscript {
  my ($self,$i)=@_;
  my $transcripts=$self->{transcripts};
  return $transcripts->[$i];
}
#---------------------------------------------------------------------
#   $t=$gene->longestTranscript();
sub longestTranscript {
  my ($self)=@_;
  my $transcripts=$self->{transcripts};
  my $n=@$transcripts;
  my $longest=$transcripts->[0];
  my $longestLength=$longest->getExtent();
  for(my $i=1 ; $i<$n ; ++$i) {
    my $transcript=$transcripts->[$i];
    my $length=$transcript->getExtent();
    if($length>$longestLength) {
      $longest=$transcript;
      $longestLength=$length;
    }
  }
  return $longest;
}
#---------------------------------------------------------------------
#   $id=$gene->getId();
sub getId
  {
    my ($self)=@_;
    return $self->{ID};
  }
#---------------------------------------------------------------------
#   $gene->setId($id);
sub setId
  {
    my ($self,$id)=@_;
    $self->{ID}=$id;
  }
#---------------------------------------------------------------------
#   ($begin,$end)=$gene->getBeginAndEnd();
sub getBeginAndEnd
  {
    my ($self)=@_;
    my $transcripts=$self->{transcripts};
    my $n=@$transcripts;
    my ($begin,$end);
    for(my $i=0 ; $i<$n ; ++$i)
      {
	my $transcript=$transcripts->[$i];
	my $b=$transcript->getBegin();
	my $e=$transcript->getEnd();
	if(!defined($begin)) {$begin=$b; $end=$e}
	else
	  {
	    if($b<$begin) {$begin=$b}
	    if($e>$end) {$end=$e}
	  }
      }
    return ($begin,$end);
  }
#---------------------------------------------------------------------
#   $gff=$gene->toGff();
sub toGff {
  my ($self)=@_;
  my $transcripts=$self->{transcripts};
  my $n=@$transcripts;
  my $gff;
  for(my $i=0 ; $i<$n ; ++$i) {
    my $transcript=$transcripts->[$i];
    $gff.=$transcript->toGff();
  }
  return $gff;
}
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------

#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------

1;

