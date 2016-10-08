package TempFilename;
use strict;

######################################################################
#
# TempFilename.pm bmajoros@tigr.org 2/12/2003
#
# 
# 
#
# Attributes:
#
# Methods:
#   $filename=TempFilename::generate();
#   $filename=TempFilename::generate($suffix);
#
#   
######################################################################


#---------------------------------------------------------------------
#                           PUBLIC METHODS
#---------------------------------------------------------------------
sub generate
{
  my ($suffix)=@_;
  if(length($suffix)<1) { $suffix="tmp" }
  while(1)
    {
      my $n=int(rand(1000000)+100000);
      my $filename="$n.$suffix";
      return($filename) unless -e $filename;
    }
}
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------

1;

