PWGS
==============


Pipeline for analyze Pooled Whole Genome Sequencing data (Pool-seq).

- Trimming with trim-fastq.pl (Popoolation).
- Alignment to Arabidopsis lyrata genome v1.0 (BWA-MEM, Li 2013).
- Removing duplicate (Picard tools).
- Selecting reads with MAPQ when > 20 (samtools, Li et al. 2009).
- Creating mpileup input file (samtool).
- Find repeated regions (RepeatMasker).
- Find insertion and deletion regions (identify-genomic-indel-regions.pl, PoPoolation).
- Remove indel and repeated regions from mpileup file (filter-pileup-by-gtf.pl, PoPoolation).
- SNP Calling with Snape. 
- SNP Calling with Varscan.


Software used:

- Bedtools (bedtools, Quinlan et al. 2010)
- trim-fastq.pl (Popoolation, Kofler et al. 2012)
- bwa mem (bwa, Li et al. 2013)
- samtools (samtools, Li et al. 2009)
- SortSam.jar (Picard tools, http://picard.sourceforge.net)
- MarkDuplicates.jar (Picard tools, http://picard.sourceforge.net)
- identify-genomic-indel-regions.pl (Popoolation, Kofler et al. 2012)
- filter-pileup-by-gtf.pl (Popoolation, Kofler et al. 2012)
- snape-pooled (Snape, Rainieri et al. 2012)
- Varscan (Varscan, Koboldt et al. 2012)

scripts:

- PWGS_ini.sh
call PWGS_paired.sh and PWGS_filtmerge.sh

- PWGS_paired.sh
Trimming, alignment

- PWGS_filtmerge.sh
Merging bams files Remove duplicate, selecting proper aligned reads.
Coverage calculations.


- PWGS_SNPcall_ini.sh
call PWGS_SNPcall.sh

- PWGS_SNPcall.sh
Filtering mpileup file, SNP calling with Snape and Varscan.





