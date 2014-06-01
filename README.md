PWGS
==============


Pipeline for analyze Pooled Whole Genome Sequencing data (Pool-seq).


Quality control with FastQC.

Alignment to Arabidopsis lyrata genome v1.0 (BWA-MEM, Li 2013).

Removing duplicate (Picard tools).

Selecting reads with MAPQ when > 20 (samtools, Li et al. 2009).

Creating mpileup input file (samtool)

Find repeated regions (RepeatMasker)

Find insertion and deletion regions  (identify-genomic-indel-regions.pl, PoPoolation)

Remove indel and repeated regions from mpileup file (filter-pileup-by-gtf.pl, PoPoolation)

SNP Calling:

- popoolation
- popoolation2
- snape


Software used:

- Bedtools (bedtools, Quinlan et al. 2010)
- trim-fastq.pl (Popoolation, Kofler et al. 2012)
- bwa mem (bwa, Li et al. 2013)
- samtools (samtools, Li et al. 2009)
- SortSam.jar (Picard tools, http://picard.sourceforge.net)
- MarkDuplicates.jar (Picard tools, http://picard.sourceforge.net)
- identify-genomic-indel-regions.pl (Popoolation, Kofler et al. 2012)
- filter-pileup-by-gtf.pl (Popoolation, Kofler et al. 2012)
- mpileup2sync.jar (Popoolation2, Kofler et al. 2012)
- snape-pooled (snape, Rainieri et al. 2012)

scripts:

PWGS_test.sh
call PWGS_worker.sh, PWGS_mergebam.sh

PWGS_worker.sh
trimming, alignment, coverage calculations, remove duplicate.

PWGS_mergebam.sh
merge different bams files, coverage calculations.

PWGS_test.sh
call PWGS_worker2.sh

PWGS_worker2.sh
Filtering of mpileup, SNP calling (popoolation2, popoolation and snape)






