package TempFilename;
use strict;
use File::Temp qw/ tempfile /;

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
#   $filename=TempFilename::generate($prefix);
#
#   
######################################################################


#---------------------------------------------------------------------
#                           PUBLIC METHODS
#---------------------------------------------------------------------
sub generate
{
  my ($prefix)=@_;
  if(length($prefix)<1) { $prefix="tmp" }
  my ($fh,$filename)=tempfile($prefix."XXXXXX");
  return $filename;
}
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------

1;

