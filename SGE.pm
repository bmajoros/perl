package SGE;
use strict;

######################################################################
#
# SGE.pm bmajoros@duke.edu 9/12/2012
#
# 
# 
#
# Attributes:
#
# Methods:
#   $sge=new SGE();
#   $n=$sge->countJobs("substring");
#   $sge->subAllDir($directoryPath,$maxConcurrent,$jobTag);
#   $sge->subAllArray(\@arrayOfFilenames,$maxConcurrent,$jobTag);
#   
######################################################################


#---------------------------------------------------------------------
#                           PUBLIC METHODS
#---------------------------------------------------------------------
sub new
{
  my ($class)=@_;
  my $self={};
  my $id=`whoami`;
  chomp $id;
  $self->{userid}=$id;
  bless $self,$class;
  return $self;
}
#---------------------------------------------------------------------
#   $n=$sge->countJobs("substring");
sub countJobs
{
  my ($self,$pattern)=@_;
  my $id=$self->{userid};
  my $count=0;
  open(IN,"qstat -u $id |") || die $id;
  <IN>; <IN>;
  while(<IN>) {
    chomp;
    $_=~/(\S.*\S)/ || die;
    $_=$1;
    my @fields=split/\s+/,$_;
    my $state=$fields[4];
    next if $state=~/d/;
    #next unless $state eq "r" || $state eq "qw" || $state eq "t";
    my $jobName=$fields[2];
    if($jobName=~/$pattern/) {++$count}
  }
  close(IN);
  return $count;
}
#---------------------------------------------------------------------
#   $sge->subAllDir($directoryPath,$maxConcurrent,$jobTag);
sub subAllDir {
  die @_ unless @_==4;
  my ($self,$path,$maxJobs,$jobTag)=@_;
  my @files=`ls $path/*.q`;
  $self->subAllArray(\@files,$maxJobs,$jobTag);
}
#---------------------------------------------------------------------
#   $sge->subAllArray(\@arrayOfFilenames,$maxConcurrent,$jobTag);
sub subAllArray {
  die unless @_==4;
  my ($self,$array,$maxJobs,$jobTag)=@_;
  my $n=@$array;
  my $numRemaining=$n;
  my $next=0;
  while($numRemaining>0) {
    my $numRunning=$self->countJobs($jobTag);
    my $freeSlots=$maxJobs-$numRunning;
    my $last=$next+$freeSlots;
    if($last>$n) { $last=$n }
    for(my $i=$next ; $i<$last ; ++$i) {
      my $file=$array->[$i];
      `qsub $file >& /dev/null`;
    }
    sleep(15);
    $next=$last;
    $numRemaining=$n-$last;
    #print STDERR "$numRemaining jobs waiting to be submitted...\n";
  }
}
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------

1;

