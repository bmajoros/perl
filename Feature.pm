package Feature;
use strict;
use Exon;

######################################################################
#
# Feature.pm 
# bmajoros@tigr.org 7/8/2002
#
#
# Attributes:
#   substrate
#   source
#   featureType
#   fivePrime
#   threePrime
#   score
#   strand : + or -
#   frame
#   extraFields
# Methods:
#   $feature=new Feature($substrate,$source,$featureType,$fivePrime,
#                        $threePrime,$score,$strand,$frame,$extraFields);
#   $gff=$feature->toGff();
#   $begin=$feature->getBegin();
#   $end=$feature->getEnd();
#   $length=$feature->getLength();
#   $feature->setBegin($begin);
#   $feature->setEnd($end);
#   $feature->printOn($filehandle);
#   $bool=$feature->overlaps($begin,$end);
#   $bool=$feature->overlapsOther($feature);
#   $slice=$feature->intersect($begin,$end);
#   $type=$feature->getType();
#   $score=$feature->getScore();
#   $feature->setScore($score);
#   $substrate=$feature->getSubstrate();
#   $feature->setSubstrate($substrate);
#   $frame=$feature->getFrame();
#   $strand=$feature->getStrand();
#   $feature->shiftCoords($delta);
#   $source=$feature->getSource();
#   $array=$feature->getExtraFields(); # array of [key,value] pairs
#   $hash=$feature->getExtraAsHash();
#   
######################################################################


#---------------------------------------------------------------------
#                           PUBLIC METHODS
#---------------------------------------------------------------------
#   $feature=new Feature($substrate,$source,$featureType,$fivePrime,
#                        $threePrime,$score,$strand,$frame,$extraFields)
sub new
{
  my ($class,$substrate,$source,$featureType,$fivePrime,$threePrime,
      $score,$strand,$frame,$extraFields)=@_;
  
  if($fivePrime>=$threePrime)
    {($fivePrime,$threePrime)=($threePrime,$fivePrime)}
  my $self=
    {
     substrate=>$substrate,
     source=>$source,
     featureType=>$featureType,
     fivePrime=>$fivePrime,
     threePrime=>$threePrime,
     score=>$score,
     strand=>$strand,
     frame=>$frame,
     extraFields=>$extraFields
    };
  bless $self,$class;

  return $self;
}
#---------------------------------------------------------------------
#   $feature->setSubstrate($substrate);
sub setSubstrate
  {
    my ($self,$substrate)=@_;
    $self->{substrate}=$substrate;
  }
#---------------------------------------------------------------------
#   $length=$feature->getLength();
sub getLength
  {
    my ($self)=@_;
    return $self->{threePrime}-$self->{fivePrime};
  }
#---------------------------------------------------------------------
#   $gff=$feature->toGff();
sub toGff
  {
    my ($self)=@_;
    my $extraFields=$self->{extraFields};
    my $substrate=$self->{substrate};
    my $source=$self->{source};
    my $featureType=$self->{featureType};
    my $fivePrime=$self->{fivePrime}+1;
    my $threePrime=$self->{threePrime};
    my $score=$self->{score};
    my $strand=$self->{strand};
    my $frame=$self->{frame};
    my $ending="";
    if(length($extraFields)>0) {$ending.="\t$extraFields"}
    return "$substrate\t$source\t$featureType\t$fivePrime\t$threePrime\t$score\t$strand\t$frame$ending\n";
  }
#---------------------------------------------------------------------
#   $substrate=$feature->getSubstrate();
sub getSubstrate
  {
    my ($self)=@_;
    return $self->{substrate};
  }
#---------------------------------------------------------------------
#   $begin=$feature->getBegin();
sub getBegin
  {
    my ($self)=@_;
    return $self->{fivePrime};
  }
#---------------------------------------------------------------------
#   $end=$feature->getEnd();
sub getEnd
  {
    my ($self)=@_;
    return $self->{threePrime};
  }
#---------------------------------------------------------------------
#   $feature->setBegin($begin);
sub setBegin
  {
    my ($self,$begin)=@_;
    $self->{fivePrime}=$begin;
  }
#---------------------------------------------------------------------
#   $feature->setEnd($end);
sub setEnd
  {
    my ($self,$end)=@_;
    $self->{threePrime}=$end;
  }
#---------------------------------------------------------------------
#   $feature->printOn($filehandle);
sub printOn
  {
    my ($self,$filehandle)=@_;
    print $filehandle $self->toGff();
  }
#---------------------------------------------------------------------
#   $bool=$feature->overlapsOther($feature);
sub overlapsOther
  {
    my ($self,$other)=@_;
    return $self->overlaps($other->getBegin(),$other->getEnd());
  }
#---------------------------------------------------------------------
#   $bool=$feature->overlaps($begin,$end);
sub overlaps
  {
    my ($self,$begin,$end)=@_;
    return 
      $self->getEnd()>$begin &&
      $self->getBegin()<$end;
  }
#---------------------------------------------------------------------
#   $slice=$feature->intersect($begin,$end);
sub intersect
  {
    my ($self,$begin,$end)=@_;
    if(!$self->overlaps($begin,$end)) {return undef}
    my $newBegin=$self->getBegin();
    my $newEnd=$self->getEnd();
    if($newBegin<$begin) {$newBegin=$begin}
    if($newEnd>$end) {$newEnd=$end}
    my $intersection=new Feature($self->{substrate},$self->{source},
				 $self->{featureType},$newBegin,$newEnd,
				 $self->{score},$self->{strand},
				 $self->{frame},$self->{extraFields});
    return $intersection;
  }
#---------------------------------------------------------------------
#   $type=$feature->getType();
sub getType
  {
    my ($self)=@_;
    return $self->{featureType};
  }
#---------------------------------------------------------------------
#   $score=$feature->getScore();
sub getScore
  {
    my ($self)=@_;
    return $self->{score};
  }
#---------------------------------------------------------------------
#   $feature->setScore($score);
sub setScore
  {
    my ($self,$score)=@_;
    $self->{score}=$score;
  }
#---------------------------------------------------------------------
#   $frame=$feature->getFrame();
sub getFrame
  {
    my ($self)=@_;
    return $self->{frame};
  }
#---------------------------------------------------------------------
#   $strand=$feature->getStrand();
sub getStrand
  {
    my ($self)=@_;
    return $self->{strand};
  }
#---------------------------------------------------------------------
#   $feature->shiftCoords($delta);
sub shiftCoords
  {
    my ($self,$delta)=@_;
    $self->{fivePrime}+=$delta;
    $self->{threePrime}+=$delta;
  }
#---------------------------------------------------------------------
#   $source=$feature->getSource();
sub getSource
{
    my ($self)=@_;
    return $self->{source};
}
#---------------------------------------------------------------------
#   $array=$feature->getExtraFields();
sub getExtraFields
{
  my ($self)=@_;
  my $extraFields=$self->{extraFields};
  my @fields=split/;/,$extraFields;
  my $ret=[];
  foreach my $field (@fields) {
    next unless $field=~/\S/;
    $field=~/([^=\s]+)[\s=]+([^=\s]+)/ || die "can't parse attribute: $field";
    my ($key,$value)=($1,$2);
    if($value=~/^"(\S+)"$/) { $value=$1 }
    push @$ret,[$key,$value];
  }
  return $ret;
}
#---------------------------------------------------------------------
#   $hash=$feature->getExtraAsHash();
sub getExtraAsHash
{
  my ($self)=@_;
  my $array=$self->getExtraFields();
  my $hash={};
  foreach my $elem (@$array) {
    my ($key,$value)=@$elem;
    $hash->{$key}=$value;
  }
  return $hash;
}
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------

1;

