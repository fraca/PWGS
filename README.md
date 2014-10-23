PWGS
=====

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

This pipeline is designed to run on Sun Grid Engine queuing system with qsub command.
The pipeline is divided in two part, the first part **PWGS_ini.sh** from the fastq files get the filtered bam files. The second part **PWGS_SNPcall_ini.sh** filter the mpileup file and call SNPs with Varscan and Snape.  
To run the pipeline:  
1. modify the input files (**PWGS_ini.sh**, **PWGS_SNPcall_ini.sh**)  
2. type the following commands:  
./PWGS_ini.sh  
./PWGS_SNPcall_ini.sh  

##PWGS_ini.sh   
Trimming, alignment, merging bams files, remove duplicates, selecting proper aligned reads, coverage calculations.

It call the scripts **PWGS_paired.sh** and **PWGS_filtmerge.sh**.

INPUT  
bin_dir= directory with the executable files  
path_gen= name with pathway of the reference genome fasta file (whithout extensions)  
n_threads= number of threads  
array_R1=( names of file.fq.gz of first ends )  
array_R2=( names of file.fq.gz of second ends )  
array_name=( names of lanes )  
nome= name of file.bam output  
min= minimum coverage  
max= maximum coverage  
min_qual= minimum base calling quality (for the trimming)  
alg_qual= minimum mapping quality  
chr_pool= number of chromosomes pooled  

OUTPUT
nome_filt.bam bam file index of the all lanes  
nome_cov file with different statistics (number of reads, coverage)  

##PWGS_SNPcall_ini.sh
Filtering mpileup file, SNP calling with Snape and Varscan.

It call **PWGS_SNPcall.sh**.

INPUT  
bin_dir= directory with the executable files  
path_gen= name with pathway of the reference genome fasta file (whithout extensions)  
n_threads= number of threads  
scaf_tot=( BED files of the chromosomes analyzed )  
scaf_num=( number of the of the chromosomes analyzed )  
scaf_fa=( fasta files of the chromosomes analyzed )  
nome= output name  
bam_in= name of the bam file  
min= minimum coverage  
max= maximum coverage  
min_qual= minimum mapping quality  
chr_pool= number of chromosomes pooled  
l_npstat= bp of the windows for NPStat  

OUTPUT  
nome.pos genomic positions analyzed  
nome_SNP_scaf/ folder with the SNP called in the output files of Varscan and Snape  

