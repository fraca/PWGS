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


# to load gsl library fro NPStat
export LD_LIBRARY_PATH="/home/fracassettim/lib/lib:$LD_LIBRARY_PATH"

$bin_dir"samtools" view -b -L $scaffold $bam_in > $nome.bam

##mpileup and filtering coverage, remove N, multiallelic positions, SNP different from reference
$bin_dir"samtools" mpileup -B -Q 0 -f $path_gen".fasta" $nome".bam" | awk '$4 > '$min' && $4 < '$max' && $5!~/([^\^][Nn]|^[Nn])|(^[AaCcGg]|[^\^][AaCcGg])(.*[^\^][Tt]|[Tt])|(^[TtCcGg]|[^\^][TtCcGg])(.*[^\^][Aa]|[Aa])|(^[TtAaGg]|[^\^][TtAaGg])(.*[^\^][Cc]|[Cc])|(^[TtCcAa]|[^\^][TtCcAa])(.*[^\^][Gg]|[Gg])/' > $nome".mpileup"


###filtering popoolation

echo "start mpileup filetring (Popool)"
date
##find indel region
perl $bin_dir"basic-pipeline/identify-genomic-indel-regions.pl" --input $nome".mpileup" --output $nome"_indel.gtf"

#add indel region with repeated regions
cat $masked_rep $nome"_indel.gtf" > $nome"_repindel.gtf"

perl $bin_dir"basic-pipeline/filter-pileup-by-gtf.pl" --gtf $nome"_repindel.gtf" --input $nome".mpileup" --output $nome"_filt.mpileup"

echo "finish mpileup filetring (Popool)"
date

awk '{print $1"_"$2}' $nome"_filt.mpileup" > $nome".pos"



## on mpileup filtered
echo "start SNP calling (NPstat, Snape) on filtered"

date
$bin_dir"npstat" -n $chr_pool -l $l_npstat -mincov $min -maxcov $max -minqual $min_qual -nolowfrew $min_all -outgroup $scaffold_fa $nome"_filt.mpileup"
theta=$(awk '{sum+=$6} END { print sum/NR}' $nome"_filt.mpileup.stats")
D=$(awk '{sum+=$13} END { print sum/NR}' $nome"_filt.mpileup.stats")
echo "#Chromosomes $nome, theta is $theta, D is $D" > $nome"_stat"

wc -l $nome".mpileup" >> $nome"_stat"
wc -l $nome".pos" >> $nome"_stat"

date
##snape
$bin_dir"snape-pooled" -nchr $chr_pool -theta $theta -D $D -fold unfolded -priortype informative < $nome"_filt.mpileup" | awk '$9 > '$pp_snape'' | awk '$5 >='$min_all'' > $nome"_filt.snape"

wc -l $nome"_filt.snape" >> $nome"_stat"
echo "finish SNP calling (NPstat, Snape) on filtered"
date

echo "Start Varscan"
date
java -Xmx2g -jar $bin_dir"VarScan.v2.3.7.jar" pileup2snp $nome"_filt.mpileup" --min-coverage $min --min-avg-qual $min_qual --min-reads2 $min_all --p-value 0.05 > $nome"_filt".varscan
wc -l $nome"_filt.varscan" >> $nome"_stat"
date

rm $nome"_filt.mpileup"
rm $nome"_filt.mpileup.params"
rm $nome"_filt.mpileup.stats"
rm $nome.bam
rm $nome.mpileup
rm $nome"_indel.gtf"
rm $nome"_indel.gtf.params"
rm $nome"_repindel.gtf"
