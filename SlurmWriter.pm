package SlurmWriter;
use strict;

######################################################################
#
# SlurmWriter.pm bmajoros@duke.edu 7/22/2015
#
# Writes slurm control files.  $numScripts controls how many scripts
# are written; if more commands are registered than scripts, each script
# can have more than one command.  The $filestem is also the job name
# stem.  $baseDir is where the jobs should run.
#
# Attributes:
#   commands : array of string
#   nice : empty, or integer (nice value)
#   mem : empty, or integer (mem value, in megabytes)
#   queue : partition name
# Methods:
#   $writer=new SlurmWriter();
#   $writer->addCommand($cmd);
#   $writer->nice(); # turns on "nice" (sets it to 100 by default)
#   $writer->mem(1500);
#   $writer->setQueue("new,all");
#   $writer->writeScripts($numScripts,$scriptDir,$jobName,
#               $baseDir,$additional_SBATCH_lines);
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
#   $writer->addCommand($cmd);
sub addCommand
{
  my ($this,$cmd)=@_;
  push @{$this->{commands}},$cmd;
}
#---------------------------------------------------------------------
#   $writer->writeScripts($numScripts,$scriptDir,$filestem,
#               $baseDir,$additional_SBATCH_lines);
sub writeScripts {
  my ($this,$numScripts,$scriptDir,$filestem,$baseDir,$moreSBATCH,
      $queue)
    =@_;
  chomp $moreSBATCH;
  if($this->{niceValue}>0) 
    { $moreSBATCH.="#SBATCH --nice=".$this->{niceValue}."\n" }
  if($this->{memValue}>0) 
    { $moreSBATCH.="#SBATCH --mem=".$this->{memValue}."\n" }
  if(length($moreSBATCH)>0) {
    unless($moreSBATCH=~/\n$/) { $moreSBATCH.="\n" }
  }
  if(length($this->{queue})>0) {
    $queue=$this->{queue};
    $queue="#SBATCH -p $queue\n";
  }
  if(-e $scriptDir) { system("rm -f $scriptDir/*.{slurm,output}") }
  system("mkdir -p $scriptDir");
  my $commands=$this->{commands};
  my $numCommands=@$commands;
  #my $commandsPerJob=int($numCommands/$numScripts);
  my $commandsPerJob=$numCommands/$numScripts;
  for(my $i=0 ; $i<$numScripts ; ++$i) {
    my $begin=int($i*$commandsPerJob);
    my $end=int(($i+1)*$commandsPerJob);
    if($i==$numScripts-1) { $end=$numCommands }
    my $id=$i+1;
    my $filename="$scriptDir/$id.slurm";
    open(OUT,">$filename") || die $filename;
    print OUT "#!/bin/tcsh
#
#SBATCH -J $filestem$id
#SBATCH -o $filestem$id.output
#SBATCH -e $filestem$id.output
#SBATCH -A $filestem$id
$queue
$moreSBATCH#
cd $baseDir
";
    for(my $j=$begin ; $j<$end ; ++$j) {
      my $command=$commands->[$j];
      print OUT "$command\n";
    }
    close(OUT);
  }
}
#---------------------------------------------------------------------
#   $writer->setQueue("new,all");
sub setQueue
{
  my ($self,$queue)=@_;
  $self->{queue}=$queue;
}
#---------------------------------------------------------------------
#   $writer->nice();
sub nice {
  my ($this,$value)=@_;
  if(!$value) { $value=100 }
  $this->{niceValue}=$value;
}
#---------------------------------------------------------------------
#   $writer->mem(1500);
sub mem {
  my ($this,$value)=@_;
  $this->{memValue}=$value;
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

