package EssexFBI;
use strict;

######################################################################
#
# EssexFBI.pm bmajoros@duke.edu 3/10/2016
#
# Provides a more convenient programmatic interface to FBI reports
# encoded as Essex objects.
#
# Attributes:
#   EssexNode *essex;
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
#   $bool=$fbiReport->mappedPTC(); # premature stop codon when status="mapped"
#   $bool=$fbiReport->mappedNMD(); # only valid when status="mapped"
#   $bool=$fbiReport->mappedNoStart(); # assumes status="mappped"
#   $bool=$fbiReport->mappedNonstop(); # no stop codon; status must = "mapped"
#   $bool=$fbiReport->refIsCoding();
#   $bool=$fbiReport->mappedIsCoding();
#   $bool=$fbiReport->lossOfCoding(); # ref is coding, alt is noncoding
#   $bool=$fbiReport->allAltStructuresLOF(); # assumes status=splicing-changes,
#          LOF (loss of function) means NMD or noncoding
#
# Private Methods:
#
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
#   $substrate=$fbiReport->getSubstate();
sub getSubstrate
{
  my ($self)=@_;

}
#---------------------------------------------------------------------
#   $transcriptID=$fbiReport->getTranscriptID();
sub getTranscriptID
{
  my ($self)=@_;

}
#---------------------------------------------------------------------
#   $geneID=$fbiReport->getGeneID();
sub getGeneID
{
  my ($self)=@_;

}
#---------------------------------------------------------------------
#   $vcfWarnings=$fbiReport->getNumVcfWarnings();
sub getNumVcfWarnings
{
  my ($self)=@_;

}
#---------------------------------------------------------------------
#   $vcfErrors=$fbiReport->getNumVcfErrors();
sub getNumVcfErrors
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $cigar=$fbiReport->getCigar();
sub getCigar
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $defline=$fbiReport->getDefline();
sub getDefline
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $transcript=$fbiReport->getRefTranscript();
sub getRefTranscript
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $transcript=$fbiReport->getMappedTranscript();
sub getMappedTranscript
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $statusString=$fbiReport->getStatusString();
#             status=mapped/splicing-changes/no-transcript
sub getStatusString
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->proteinDiffers();
sub proteinDiffers
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $percent=$fbiReport->getProteinMatch();
sub getProteinMatch
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->frameshift();
sub frameshift
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $percent=$fbiReport->frameshiftPercentMismatch();
sub frameshiftPercentMismatch
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $nucs=$fbiReport->frameshiftNucMismatch();
sub frameshiftNucMismatch
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->mappedPTC(); # premature stop codon when status="mapped"
sub mappedPTC
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->mappedNMD(); # only valid when status="mapped"
sub mappedNMD
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->mappedNoStart(); # assumes status="mappped"
sub mappedNoStart
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->mappedNonstop(); # no stop codon; status must = "mapped"
sub mappedNonstop
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->refIsCoding();
sub refIsCoding
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->mappedIsCoding();
sub mappedIsCoding
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->lossOfCoding(); # ref is coding, alt is noncoding
sub lossOfCoding
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#   $bool=$fbiReport->allAltStructuresLOF(); # assumes status=splicing-changes,
#          LOF (loss of function) means NMD or noncoding
sub allAltStructuresLOF
{
  my ($self)=@_;
  
}
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------






#---------------------------------------------------------------------
#                         PRIVATE METHODS
#---------------------------------------------------------------------


#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------
#---------------------------------------------------------------------

1;

