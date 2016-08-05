package EssexICE;
use strict;
use EssexNode;
use Transcript;

######################################################################
#
# EssexICE.pm bmajoros@duke.edu 3/10/2016
#
# Provides a more convenient programmatic interface to ICE reports
# encoded as Essex objects.
#
# Attributes:
#   EssexNode *essex;
#   float minPercentMatch : minimum % match for proteins to not cause LOF
# Methods:
#   $iceReport=new EssexICE($essexReportElem);
#   $iceReport->changeMinPercentMatch($x); # example: 75.3
#   $substrate=$iceReport->getSubstrate();
#   $transcriptID=$iceReport->getTranscriptID();
#   $geneID=$iceReport->getGeneID();
#   $vcfWarnings=$iceReport->getNumVcfWarnings();
#   $vcfErrors=$iceReport->getNumVcfErrors();
#   $cigar=$iceReport->getCigar();
#   $transcript=$iceReport->getRefTranscript();
#   $transcript=$iceReport->getMappedTranscript();
#   $statusString=$iceReport->getStatusString();
#     status = mapped/splicing-changes/no-transcript/bad-annotation
#   $bool=$iceReport->hasBrokenSpliceSite();
#   $array=$report->getBrokenSpliceSites(); [pos,type=GT/AG]
#   $array=$iceReport->getAltTranscripts();
#   $bool=$iceReport->proteinDiffers();
#   $percent=$iceReport->getProteinMatch(); # example: 98.57 (whole number)
#   $bool=$iceReport->frameshift();
#   $percent=$iceReport->frameshiftPercentMismatch(); # example: 83 (whole num)
#   $nucs=$iceReport->frameshiftNucMismatch();
#   $bool=$iceReport->mappedPTC(); # premature stop codon when status="mapped"
#   $bool=$iceReport->mappedNMD(50); # only valid when status="mapped"
#   $bool=$iceReport->mappedNoStart(); # assumes status="mappped"
#   $bool=$iceReport->mappedNonstop(); # no stop codon; status must = "mapped"
#   $bool=$iceReport->refIsCoding();
#   $bool=$iceReport->mappedIsCoding();
#   $bool=$iceReport->lossOfCoding(); # ref is coding, alt is noncoding
#   $bool=$iceReport->allAltStructuresLOF(); # assumes status=splicing-changes,
#          LOF (loss of function) means NMD or noncoding
#   $bool=$iceReport->allExonSkippingLOF(); # assumes status=splicing-changes
#   $bool=$iceReport->allExonSkippingNMD(); # assumes status=splicing-changes
#
# Private Methods:
#
######################################################################


#---------------------------------------------------------------------
#                           PUBLIC METHODS
#---------------------------------------------------------------------
#   $essexICE=new EssexICE($essexReportElem);
sub new
{
  my ($class,$report)=@_;

  my $self=
    {
     essex=>$report,
     minPercentMatch=>70,
    };
  bless $self,$class;

  return $self;
}
#---------------------------------------------------------------------
#   $substrate=$iceReport->getSubstrate();
sub getSubstrate
{
  my ($self)=@_;
  return $self->{essex}->getAttribute("substrate");
}
#---------------------------------------------------------------------
#   $transcriptID=$iceReport->getTranscriptID();
sub getTranscriptID
{
  my ($self)=@_;
  return $self->{essex}->getAttribute("transcript-ID");
}
#---------------------------------------------------------------------
#   $geneID=$iceReport->getGeneID();
sub getGeneID
{
  my ($self)=@_;
  return $self->{essex}->getAttribute("gene-ID");
}
#---------------------------------------------------------------------
#   $vcfWarnings=$iceReport->getNumVcfWarnings();
sub getNumVcfWarnings
{
  my ($self)=@_;
  return 0+$self->{essex}->getAttribute("vcf-warnings");
}
#---------------------------------------------------------------------
#   $vcfErrors=$iceReport->getNumVcfErrors();
sub getNumVcfErrors
{
  my ($self)=@_;
  return 0+$self->{essex}->getAttribute("vcf-errors");
}
#---------------------------------------------------------------------
#   $cigar=$iceReport->getCigar();
sub getCigar
{
  my ($self)=@_;
  return $self->{essex}->getAttribute("alignment");
  
}
#---------------------------------------------------------------------
#   $defline=$iceReport->getDefline();
sub getDefline
{
  my ($self)=@_;
  return $self->{essex}->getAttribute("defline");
  
}
#---------------------------------------------------------------------
#   $transcript=$iceReport->getRefTranscript();
sub getRefTranscript
{
  my ($self)=@_;
  my $trans=$self->{essex}->findChild("reference-transcript");
  die "no reference transcript" unless $trans;
  return new Transcript($trans);
}
#---------------------------------------------------------------------
#   $array=$iceReport->getAltTranscripts();
sub getAltTranscripts
{
  my ($self)=@_;
  my $altElem=$self->{essex}->findDescendent("alternate-structures");
  my $array=[];
  if($altElem) {
    my $children=$altElem->findChildren("transcript");
    my $n=@$children;
    for(my $i=0 ; $i<$n ; ++$i) {
      my $child=$children->[$i];
      my $transcript=new Transcript($child);
      my $change=$child->getAttribute("structure-change");
      $transcript->{structureChange}=$change;
      push @$array,$transcript;
    }
  }
  return $array;
}
#---------------------------------------------------------------------
#   $transcript=$iceReport->getMappedTranscript();
sub getMappedTranscript
{
  my ($self)=@_;
  my $trans=$self->{essex}->findChild("mapped-transcript");
  #die "no mapped transcript" unless $trans;
  return $trans ? new Transcript($trans) : undef;
}
#---------------------------------------------------------------------
#   $statusString=$iceReport->getStatusString();
#             status=mapped/splicing-changes/no-transcript
sub getStatusString
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  die "empty status" unless $status->numElements()>0;
  my $string=$status->getIthElem(0);
  return $string;
}
#---------------------------------------------------------------------
#   $bool=$iceReport->hasBrokenSpliceSite();
sub hasBrokenSpliceSite
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  die "empty status" unless $status->numElements()>0;
  return $status->findChild("broken-donor") || 
    $status->findChild("broken-acceptor");
}
#---------------------------------------------------------------------
#   $array=$report->getBrokenSpliceSites(); [pos,type=GT/AG]
sub getBrokenSpliceSites
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  die "empty status" unless $status->numElements()>0;
  my $donors=$status->findChildren("broken-donor");
  my $acceptors=$status->findChildren("broken-acceptor");
  my $array=[];
  foreach my $donor (@$donors)
    { push @$array,[$donor->getIthElem(0),"GT"] }
  foreach my $acceptor (@$acceptors)
    { push @$array,[$acceptor->getIthElem(0),"AG"] }
  return $array;
}
#---------------------------------------------------------------------
#   $bool=$iceReport->proteinDiffers();
sub proteinDiffers
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  die "empty status" unless $status->numElements()>0;
  my $differs=$status->findChild("protein-differs");
  if(defined($differs)) { return 1 } else { return 0 }
}
#---------------------------------------------------------------------
#   $percent=$iceReport->getProteinMatch();
sub getProteinMatch
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  die "empty status" unless $status->numElements()>0;
  my $differs=$status->findChild("protein-differs");
  die "no protein-differs element found" unless $differs;
  my $match=$differs->findChild("percent-match");
  die "no percent-match element found" unless $match;
  die "percent-match has no elements" unless $match->numElements()>0;
  return 0+$match->getIthElem(0);
}
#---------------------------------------------------------------------
#   $bool=$iceReport->frameshift();
sub frameshift
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  die "empty status" unless $status->numElements()>0;
  my $frameshift=$status->findChild("frameshift");
  return $frameshift ? 1 : 0;
}
#---------------------------------------------------------------------
#   $percent=$iceReport->frameshiftPercentMismatch();
sub frameshiftPercentMismatch
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  die "empty status" unless $status->numElements()>0;
  my $frameshift=$status->findChild("frameshift");
  die "no frameshift" unless $frameshift;
  die "frameshift has no children" unless $frameshift->numElements()>0;
  my $percent=$frameshift->findChild("percent-phase-mismatch");
  die "no percent-phase-mismatch element found" unless $percent;
  die "percent-phase-mismatch has no elements" 
    unless $percent->numElements()>0;
  my $string=$percent->getIthElem(0);
  $string=~/(\S+)%/ || die "Can't parse percent: $string";
  my $num=0+$1;
  return $num;
}
#---------------------------------------------------------------------
#   $nucs=$iceReport->frameshiftNucMismatch();
sub frameshiftNucMismatch
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  die "empty status" unless $status->numElements()>0;
  my $frameshift=$status->findChild("frameshift");
  die "no frameshift" unless $frameshift;
  die "frameshift has no children" unless $frameshift->numElements()>0;
  my $nt=$frameshift->findChild("nt-with-phase-mismatch");
  die "no nt-with-phase-mismatch element found" unless $nt;
  die "nt-with-phase-mismatch has no elements" unless $nt->numElements()>0;
  my $string=$nt->getIthElem(0);
  return $0+$string;
}
#---------------------------------------------------------------------
#   $bool=$iceReport->mappedPTC(); # premature stop codon when status="mapped"
sub mappedPTC
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  my $PTC=$status->findChild("premature-stop");
  return $PTC ? 1 : 0;
}
#---------------------------------------------------------------------
#   $bool=$iceReport->mappedNMD($fifty); # only valid when status="mapped"
sub mappedNMD
{
  my ($self,$fifty)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  my $PTC=$status->findChild("premature-stop");
  if(!$PTC) { return 0 }
  die "premature-stop element has no children" unless $PTC->numElements()>0;
  return($PTC->getIthElem(0) eq "NMD" &&
	 $PTC->getAttribute("EJC-distance")>=$fifty);
}
#---------------------------------------------------------------------
#   $bool=$iceReport->mappedNoStart(); # assumes status="mappped"
sub mappedNoStart
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  return $status->hasDescendentOrDatum("no-start-codon");
}
#---------------------------------------------------------------------
#   $bool=$iceReport->mappedNonstop(); # no stop codon; status must = "mapped"
sub mappedNonstop
{
  my ($self)=@_;
  my $status=$self->{essex}->findChild("status");
  die "no status" unless $status;
  return $status->hasDescendentOrDatum("nonstop-decay");
}
#---------------------------------------------------------------------
#   $bool=$iceReport->refIsCoding();
sub refIsCoding
{
  my ($self)=@_;
  my $ref=$self->{essex}->findChild("reference-transcript");
  die "no reference-transcript" unless $ref;
  return $ref->getAttribute("type") eq "protein-coding";
}
#---------------------------------------------------------------------
#   $bool=$iceReport->mappedIsCoding();
sub mappedIsCoding
{
  my ($self)=@_;
  my $mapped=$self->{essex}->findChild("mapped-transcript");
  die "no mapped-transcript" unless $mapped;
  return $mapped->getAttribute("type") eq "protein-coding";
}
#---------------------------------------------------------------------
#   $bool=$iceReport->lossOfCoding(); # ref is coding, alt is noncoding
sub lossOfCoding
{
  my ($self)=@_;
  return $self->refIsCoding() && !$self->mappedIsCoding();
}
#---------------------------------------------------------------------
#   $bool=$iceReport->allAltStructuresLOF(); # assumes status=splicing-changes,
#          LOF (loss of function) means NMD or noncoding
sub allAltStructuresLOF
{
  my ($self)=@_;
  my $alts=$self->{essex}->findDescendents("alternate-structures");
  die "no alternate-structures" unless @$alts>0;
  $alts=$alts->[0];
  my $refIsCoding=$self->refIsCoding();
  my $transcripts=$alts->findDescendents("transcript");
  foreach my $transcript (@$transcripts) {
    my $array=$transcript->findDescendents("fate");
    die "no fate" unless @$array>0;
    my $fate=$array->[0];
    die "empty fate" unless $fate && $fate->numElements()>0;
    my $string=$fate->getIthElem(0);
    my $LOF=0;
    if($string eq "NMD") { $LOF=1 }
    elsif($string eq "nonstop-decay") { $LOF=1 }
    elsif($refIsCoding && $string eq "noncoding") { $LOF=1 }
    elsif($string eq "protein-differs") {
      my $match=$fate->findChild("percent-match");
      die "no percent-match in fate" unless $match;
      die "percent-match has no children" unless $match->numElements()>0;
      my $percent=0+$match->getIthElem(0);
      if($percent<$self->{minPercentMatch}) { $LOF=1 }
    }
    if(!$LOF) { return 0 }
  }
  return 1;
}
#---------------------------------------------------------------------
#   $bool=$iceReport->allExonSkippingLOF(); # assumes status=splicing-changes,
sub allExonSkippingLOF
{
  my ($self)=@_;
  my $alts=$self->{essex}->findDescendents("alternate-structures");
  die "no alternate-structures" unless @$alts>0;
  $alts=$alts->[0];
  my $refIsCoding=$self->refIsCoding();
  my $transcripts=$alts->findDescendents("transcript");
  foreach my $transcript (@$transcripts) {
    next unless 
      $transcript->getAttribute("structure-change") eq "exon-skipping";
    my $fate=$transcript->findDescendent("fate");
    die "no fate" unless $fate && $fate->numElements()>0;
    my $string=$fate->getIthElem(0);
    my $LOF=0;
    if($string eq "NMD") { $LOF=1 }
    elsif($string eq "nonstop-decay") { $LOF=1 }
    elsif($refIsCoding && $string eq "noncoding") { $LOF=1 }
    elsif($string eq "protein-differs") {
      my $match=$fate->findChild("percent-match");
      die "no percent-match in fate" unless $match;
      die "percent-match has no children" unless $match->numElements()>0;
      my $percent=0+$match->getIthElem(0);
      if($percent<$self->{minPercentMatch}) { $LOF=1 }
    }
    if(!$LOF) { return 0 }
  }
  return 1;
}
#---------------------------------------------------------------------
#   $bool=$iceReport->allExonSkippingNMD(); # assumes status=splicing-changes,
sub allExonSkippingNMD
{
  my ($self)=@_;
  my $alts=$self->{essex}->findDescendents("alternate-structures");
  die "no alternate-structures" unless @$alts>0;
  $alts=$alts->[0];
  my $refIsCoding=$self->refIsCoding();
  my $transcripts=$alts->findDescendents("transcript");
  foreach my $transcript (@$transcripts) {
    next unless
      $transcript->getAttribute("structure-change") eq "exon-skipping";
    my $fate=$transcript->findDescendent("fate");
    die "no fate" unless $fate && $fate->numElements()>0;
    my $string=$fate->getIthElem(0);
    if($string ne "NMD") { return 0 }
  }
  return 1;
}
#---------------------------------------------------------------------
#   $iceReport->changeMinPercentMatch($x); # example: 75.3
sub changeMinPercentMatch
{
  my ($self,$x)=@_;
  $self->{minPercentMatch}=$x;
}
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

