#! /bin/bash

# Request "/bin/bash" as shell
#$ -S /bin/bash

# Start the job from the current working directory
#$ -cwd

# Merge standard output and standard error
#$ -j y

# Set the queue for the job: any queue on machine "smp" (kepler)
#$ -q *@smp

###############################################################################

n_threads= expr $n_threads
bin_dir="/home/fracassettim/pipe_bin/"
path_gen="/scratch/fracassettim/Genome_Alyrata/"


nome="blabla_$nome2"

perl $bin_dir"/basic-pipeline/trim-fastq.pl" --input1 $lane1 --input2 $lane2 --output $nome --quality-threshold $min_qual --min-length 50 --no-5p-trim --disable-zipped-output --fastq-type sanger | grep -A 4 FINISHED > $nome2"_mystat"


##alignement bwa  0.7.5a-r405 (version on galileo/kepler you have to use it)
##remember to index the reference genome.

bwa mem -M -t $n_threads $path_gen"Alyrata_all.fasta" $nome"_1" $nome"_2" > $nome".sam" #let -M maybe error on Picard MarkDuplicates

##samtools 0.1.19-44428cd (same version on server and office PC)
## picard-tools-1.108

samtools view -@ $n_threads -Sb $nome".sam" > $nome".bam"

echo 'All reads in bam' >> $nome2"_mystat"
samtools view -c $nome".bam" >> $nome2"_mystat" #error core fault if I put -c and -2 together

java -Xmx2g -jar $bin_dir"SortSam.jar" I=$nome".bam" O=$nome"_sort.bam" VALIDATION_STRINGENCY=SILENT SO=coordinate

java -Xmx2g -jar $bin_dir"MarkDuplicates.jar" I=$nome"_sort.bam" O=$nome"_rd.bam" M=$nome"_dupstat.txt" VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true

echo 'reads after picard MarkDuplicates' >> $nome2"_mystat"
samtools view  -c $nome"_rd.bam" >> $nome2"_mystat"

##from here split between Plastid and Nuclear

samtools view -@ $n_threads -L $path_gen"list_Plastid" $nome"_rd.bam" -b > $nome2"_rd_Plastid.bam"

echo 'reads in the plastid genome' >> $nome2"_mystat"
samtools view -c $nome2"_rd_Plastid.bam" >> $nome2"_mystat"

samtools view -@ $n_threads -L $path_gen"list_Nuclear" $nome"_rd.bam" -b > $nome"_rd_Nuclear.bam"

echo 'reads in the nuclear genome' >> $nome2"_mystat"
samtools view -c $nome"_rd_Nuclear.bam" >> $nome2"_mystat"

samtools view -@ $n_threads -q $min_qual -f 0x0002 -F 0x0004 -F 0x0008 -b $nome"_rd_Nuclear.bam" > $nome2"_filt.bam"

samtools index $nome2"_filt.bam"

echo 'reads after quality filtering' >> $nome2"_mystat"
samtools view -c $nome2"_filt.bam" >> $nome2"_mystat"

echo -e 'scaffold\tbp_length\tn_reads' >> $nome2"_mystat"
samtools idxstats $nome2"_filt.bam" >> $nome2"_mystat"

echo -e 'bedtools coverage' >> $nome2"_mystat"

$bin_dir"/bedtools/genomeCoverageBed" -ibam $nome2"_filt.bam" >> $nome2"_mystat"

rm "$nome"*

