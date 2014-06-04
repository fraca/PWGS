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
bin_dir="/scratch/fracassettim/pipe_bin/"
path_gen="/scratch/fracassettim/Genome_Alyrata/"

#from PWGS_test2
#scaffold="list_scaffold1"
#bam_in="test.bam"
#nome="blabla"


samtools view -b -L $path_gen$scaffold $bam_in > $nome.bam

##mpileup and filtering coverage

samtools mpileup -B -Q 0 -f $path_gen"Alyrata_all.fasta" $nome".bam" | awk '$4 > '$min' && $4 < '$max > $nome".mpileup"


##find indel region
perl $bin_dir"basic-pipeline/identify-genomic-indel-regions.pl" --input $nome".mpileup" --output $nome"_indel.gtf"

#add indel region with repeated regions
cat $path_gen"Alyrata_all.fasta.out.gff" $nome"_indel.gtf" > $nome"_repindel.gtf"

perl $bin_dir"basic-pipeline/filter-pileup-by-gtf.pl" --gtf $nome"_repindel.gtf" --input $nome".mpileup" --output $nome"_filt.mpileup"

echo "start SNP calling"

##SNP calling 

date
##popoolation2 

java -ea -Xmx5000m -jar $bin_dir"popoolation2_1201/mpileup2sync.jar" --input $nome"_filt.mpileup" --output $nome".sync" --fastq-type sanger --min-qual $min_qual

#remove multiallelic from mpileup


date

##popoolation
perl $bin_dir"Variance-sliding.pl" --measure pi --fastq-type sanger --input $nome"_filt.mpileup" --min-count 2 --min-qual $min_qual --min-coverage $min --max-coverage $max --pool-size $((chr_pool/2)) --window-size 100000 --step-size 100000 --output $nome.varslid.pi --snp-output $nome"_temp.popool"
grep -e '^$\|>scaffold' -v $nome"_temp.popool" > $nome".popool"

date

##snape
$bin_dir"snape-pooled" -nchr $chr_pool -theta $theta -D $D -fold unfolded -priortype informative < $nome"_filt.mpileup" | awk '$9 > 0.9' > $nome"_ui.snape"

date

rm $nome.bam
rm $nome.mpileup
rm $nome"_indel.gtf"
rm $nome"_indel.gtf.params"
rm $nome"_repindel.gtf"
rm $nome"_temp.popool"




