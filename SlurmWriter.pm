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
# Methods:
#   $writer=new SlurmWriter();
#   $writer->addCommand($cmd);
#   $writer->writeScripts($numScripts,$scriptDir,$filestem,
#               "lowmem"|"himem",$baseDir,$additional_SBATCH_lines);
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
#               "lowmem"|"himem",$baseDir,$additional_SBATCH_lines);
sub writeScripts {
  my ($this,$numScripts,$scriptDir,$filestem,$himem,$baseDir,$moreSBATCH)
    =@_;
  chomp $moreSBATCH;
  if(length($moreSBATCH)>0) {
    unless($moreSBATCH=~/\n$/) { $moreSBATCH.="\n" }
  }
  if(-e $scriptDir) { system("rm -f $scriptDir/*.{slurm,output}") }
  system("mkdir -p $scriptDir");
  my $commands=$this->{commands};
  my $numCommands=@$commands;
  my $commandsPerJob=int($numCommands/$numScripts);
  for(my $i=0 ; $i<$numScripts ; ++$i) {
    my $begin=$i*$commandsPerJob;
    my $end=($i+1)*$commandsPerJob;
    if($i==$numScripts-1) { $end=$numCommands }
    my $id=$i+1;
    my $filename="$scriptDir/$filestem$id.slurm";
    open(OUT,">$filename") || die $filename;
    print OUT "#!/bin/bash
#
#SBATCH -p $himem
#SBATCH -J $filestem$id
#SBATCH -o $filestem$id.output
#SBATCH -e $filestem$id.output
#SBATCH -A $filestem$id
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

