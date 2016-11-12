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
#   threads : number of CPUs requested
# Methods:
#   $writer=new SlurmWriter();
#   $writer->addCommand($cmd);
#   $writer->nice(); # turns on "nice" (sets it to 100 by default)
#   $writer->mem(1500);
#   $writer->threads(16);
#   $writer->setQueue("new,all");
#   $writer->writeScripts($numScripts,$scriptDir,$jobName,$runDir,$maxParallel,
#                         $additional_SBATCH_lines);
#   $writer->writeArrayScript($slurmDir,$jobName,$runDir,$maxParallel,
#                             $additional_SBATCH_lines);
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
  my ($this,$numScripts,$scriptDir,$filestem,$baseDir,$moreSBATCH)=@_;
  chomp $moreSBATCH;
  if($this->{niceValue}>0) 
    { $moreSBATCH.="#SBATCH --nice=".$this->{niceValue}."\n" }
  if($this->{memValue}>0) 
    { $moreSBATCH.="#SBATCH --mem=".$this->{memValue}."\n" }
  if($this->{threads}>0)
    { $moreSBATCH.="#SBATCH --cpus-per-task=".$this->{threads}."\n" }
  if(length($moreSBATCH)>0) {
    unless($moreSBATCH=~/\n$/) { $moreSBATCH.="\n" }
  }
  my $queue;
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
    print OUT "#!/bin/sh
#
#SBATCH --get-user-env
#SBATCH -J $filestem$id
#SBATCH -o $scriptDir/$filestem$id.output
#SBATCH -e $scriptDir/$filestem$id.output
#SBATCH -A $filestem$id
$queue$moreSBATCH#
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
#   $writer->threads(16);
sub threads {
  my ($this,$value)=@_;
  $this->{threads}=$value;
}
#---------------------------------------------------------------------
#   $writer->mem(1500);
sub mem {
  my ($this,$value)=@_;
  $this->{memValue}=$value;
}
#---------------------------------------------------------------------
#   $writer->writeArrayScript($slurmDir,$jobName,$runDir,$maxParallel,
#                             $additional_SBATCH_lines);
sub writeArrayScript {
  my ($this,$slurmDir,$jobName,$runDir,$maxParallel,$moreSBATCH)=@_;
  die "specify maxParallel parameter" unless $maxParallel>0;
  chomp $moreSBATCH;
  if($this->{niceValue}>0) 
    { $moreSBATCH.="#SBATCH --nice=".$this->{niceValue}."\n" }
  if($this->{memValue}>0) 
    { $moreSBATCH.="#SBATCH --mem=".$this->{memValue}."\n" }
  if($this->{threads}>0)
    { $moreSBATCH.="#SBATCH --cpus-per-task=".$this->{threads}."\n" }
  if(length($moreSBATCH)>0) {
    unless($moreSBATCH=~/\n$/) { $moreSBATCH.="\n" } }
  my $queue;
  if(length($this->{queue})>0) {
    $queue=$this->{queue};
    $queue="#SBATCH -p $queue\n"; }
  if(-e $slurmDir)
    { system("rm -f $slurmDir/*.sh $slurmDir/array.slurm $slurmDir/outputs/*.output") }
  system("mkdir -p $slurmDir/outputs");
  my $commands=$this->{commands};
  my $numCommands=@$commands;
  my $numJobs=$numCommands;
  my $TCSH=`which sh`; chomp $TCSH;
  for(my $i=0 ; $i<$numCommands ; ++$i) {
    my $command=$commands->[$i];
    my $index=$i+1;
    my $filename="$slurmDir/command$index.sh";
    open(OUT,">$filename") || die $filename;
    #print OUT "#!$TCSH\n";
    print OUT "#/bin/bash\n";
    print OUT "$command\n";
    close(OUT);
    system("chmod +x $filename");
  }
  my $filename="$slurmDir/array.slurm";
  open(OUT,">$filename") || die $filename;
  print OUT "#!/bin/sh
#
#SBATCH --get-user-env
#SBATCH -J $jobName
#SBATCH -A $jobName
#SBATCH -o $slurmDir/outputs/\%a.output
#SBATCH -e $slurmDir/outputs/\%a.output
#SBATCH --array=1-$numJobs\%$maxParallel
$queue$moreSBATCH#
$slurmDir/command\${SLURM_ARRAY_TASK_ID}.sh
";
  close(OUT);
}
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------

1;

