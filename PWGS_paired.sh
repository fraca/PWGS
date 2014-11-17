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


nome="bla_paired_$nome2"

perl $bin_dir"/basic-pipeline/trim-fastq.pl" --input1 $lane1 --input2 $lane2 --output $nome --quality-threshold $min_qual --min-length 50 --no-5p-trim --disable-zipped-output --fastq-type sanger | grep -A 4 FINISHED > $nome2"_mystat"


##alignement bwa mem
##remember to index the reference genome.

$bin_dir"bwa" mem -M -t $n_threads $path_gen".fasta" $nome"_1" $nome"_2" > $nome".sam" #let -M maybe error on Picard MarkDuplicates



$bin_dir"samtools" view -@ $n_threads -Sb $nome".sam" > $nome".bam"

echo 'All reads in bam' >> $nome2"_mystat"
$bin_dir"samtools" view -c $nome".bam" >> $nome2"_mystat" #error core fault if I put -c and -2 together

#####################################################################
###Filtering mapped reads
#####################################################################

$bin_dir"samtools" view -@ $n_threads -q $alg_qual -f 0x0002 -F 0x0004 -F 0x0008 -b $nome".bam" > $nome"_filt.bam"

$bin_dir"samtools" sort -@ $n_threads $nome"_filt.bam" $nome2

$bin_dir"samtools" index $nome2".bam"

echo 'reads filtered' >> $nome2"_mystat"

$bin_dir"samtools" view -c $nome2".bam" >> $nome2"_mystat"


rm "$nome"*
