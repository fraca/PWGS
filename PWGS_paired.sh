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


##alignement bwa  0.7.5a-r405 (version on galileo/kepler you have to use it)
##remember to index the reference genome.

$bin_dir"bwa" mem -M -t $n_threads $path_gen".fasta" $nome"_1" $nome"_2" > $nome".sam" #let -M maybe error on Picard MarkDuplicates

##samtools 0.1.19-44428cd (same version on server and office PC)

$bin_dir"samtools" view -@ $n_threads -Sb $nome".sam" > $nome".bam"

$bin_dir"samtools" sort -@ $n_threads $nome".bam" $nome2

echo 'All reads in bam' >> $nome2"_mystat"
$bin_dir"samtools" view -c $nome2".bam" >> $nome2"_mystat" #error core fault if I put -c and -2 together


rm "$nome"*
