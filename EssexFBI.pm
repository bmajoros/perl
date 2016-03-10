package EssexFBI;
use strict;

######################################################################
#
# EssexFBI.pm bmajoros@duke.edu 3/10/2016
#
# 
# 
#
# Attributes:
#
# Methods:
#   $fbiReport=new EssexFBI($essexReportElem);
#   $substrate=$fbiReport->getSubstate();
#   $transcriptID=$fbiReport->getTranscriptID();
#   $geneID=$fbiReport->getGeneID();
#   $vcfWarnings=$fbiReport->getNumVcfWarnings();
#   $vcfErrors=$fbiReport->getNumVcfErrors();
#   $cigar=$fbiReport->getCigar();
#   $defline=$fbiReport->getDefline();
#   $transcript=$fbiReport->getRefTranscript();
#   $transcript=$fbiReport->getMappedTranscript();
#   $statusString=$fbiReport->getStatusString();
#             status=mapped/splicing-changes/no-transcript
#   $bool=$fbiReport->proteinDiffers();
#   $percent=$fbiReport->getProteinMatch();
#   $bool=$fbiReport->frameshift();
#   $percent=$fbiReport->frameshiftPercentMismatch();
#   $nucs=$fbiReport->frameshiftNucMismatch();
#   $bool=$fbiReport->PTC(); # premature stop codon when status="mapped"
#   $bool=$fbiReport->NMD(); # only valid when status="mapped"
# Private Methods:
#   $self->parseReport($report);
######################################################################


#---------------------------------------------------------------------
#                           PUBLIC METHODS
#---------------------------------------------------------------------
#   $essexFBI=new EssexFBI($essexReportElem);
sub new
{
  my ($class,$report)=@_;
  
  my $self={};
  bless $self,$class;

  $self->parse($report);

  return $self;
}
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------


#---------------------------------------------------------------------
#   $self->parseReport($report);
sub parseReport
{
  my ($report)=@_;
  
}
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------

1;

