PWGS
=====

Pipeline for analyzing Pooled Whole-Genome Sequencing pair-end data (pool-seq).

[M. Fracassetti et al. (2015). Validation of pooled whole-genome re-sequencing in *Arabidopsis lyrata*.](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0140462)

- Trimming with trim-fastq.pl (PoPoolation).
- Alignment to Arabidopsis lyrata genome v1.0 (BWA-MEM, Li 2013).
- Removal of duplicates (Picard tools).
- Selection of reads with MAPQ >20 (SAMtools, Li et al. 2009).
- Creating mpileup input file (SAMtool).
- Find repeated regions (RepeatMasker).
- Find regions of insertions and deletions (identify-genomic-indel-regions.pl, PoPoolation).
- Removing of indels and repeated regions from mpileup file (filter-pileup-by-gtf.pl, PoPoolation).
- SNP calling with Snape. 
- SNP calling with VarScan.


Software used:

- bedtools (BEDTools, Quinlan et al. 2010)
- trim-fastq.pl (PoPoolation, Kofler et al. 2012)
- bwa mem (BWA, Li et al. 2013)
- samtools (SAMtools, Li et al. 2009)
- SortSam.jar (Picard tools, http://picard.sourceforge.net)
- MarkDuplicates.jar (Picard tools, http://picard.sourceforge.net)
- identify-genomic-indel-regions.pl (PoPoolation, Kofler et al. 2012)
- filter-pileup-by-gtf.pl (PoPoolation, Kofler et al. 2012)
- snape-pooled (Snape, Raineri et al. 2012)
- VarScan (VarScan, Koboldt et al. 2012)
- NPStat (NPStat, Ferretti et al. 2013)

This pipeline is designed to run on Sun Grid Engine queuing system with qsub command.
The pipeline is divided into two parts. The first part - **PWGS_ini.sh** - starts with fastq files as input and ends with filtered bam files as output. The second part - **PWGS_SNPcall_ini.sh** - filters mpileup files and calls SNPs with VarScan and Snape.
To run the pipeline:  
1. modify the input files (**PWGS_ini.sh**, **PWGS_SNPcall_ini.sh**)  
2. type in the following commands:  
./PWGS_ini.sh  
./PWGS_SNPcall_ini.sh  

## PWGS_ini.sh   
Trimming, alignment, merging of bams files, removal of duplicates, selection of properly aligned reads, coverage calculations.  
It calls the scripts **PWGS_paired.sh** and **PWGS_filtmerge.sh**.

INPUT  
bin_dir= directory with the executable files  
path_gen= name with pathway of the reference genome fasta file (whithout extensions)  
n_threads= number of threads  
array_R1=( names of file.fq.gz of first ends )  
array_R2=( names of file.fq.gz of second ends )  
array_name=( names of lanes )  
array_bed=( names of the bed file to split bam output file )  
nome_bed=( output names for the splitted bam output file  )  
nome= name of output file  
min= minimum coverage  
max= maximum coverage  
min_qual= minimum base calling quality (for the trimming)  
alg_qual= minimum mapping quality  
chr_pool= number of chromosomes pooled  


OUTPUT
nome_nome_bed.bam bam files index of all lanes  
nome_nome_bed_bedtools BEDTools outputs  
nome_cov file with different statistics (number of reads, coverage)  


## PWGS_SNPcall_ini.sh
Filtering mpileup file, SNP calling with Snape and VarScan.  
It calls **PWGS_SNPcall.sh**.

INPUT  
bin_dir= directory with the executable files  
path_gen= name with pathway of the reference genome fasta file (whithout extensions)  
n_threads= number of threads  
scaf_tot=( bed files of the chromosomes analyzed )  
scaf_num=( names of the of the chromosomes analyzed )  
scaf_fa=( fasta files of the chromosomes analyzed for NPStat )  
nome= output name  
bam_in= name of the bam file  
min= minimum read depth  
max= maximum read depth  
min_qual= minimum mapping quality  
chr_pool= number of chromosomes pooled  
l_npstat= bp of the windows for NPStat  
min_all= minimum allele count for Snape, VarScan and NPStat  
pp_snape= posterior probability threshold for Snape  
masked_rep= file gff of genomic interspersed repeats regions  

OUTPUT  
nome_SNP_scaf/scaf.BED bed file with all genomic positions analyzed  
nome_SNP_scaf/scaf.varscan SNPs called with VarScan  
nome_SNP_scaf/scaf.snape SNPs called with Snape  
nome_SNP_scaf/scaf_stat file with number of SNPs called  


