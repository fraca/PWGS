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


#select one scaffold, filter based to BED
#mpileup and filtering coverage, remove N, multiallelic positions, SNP different from reference
$bin_dir"samtools" view -b -L $scaffold $bam_in | $bin_dir"bedtools/bedtools" intersect -abam stdin -b $BED_in | $bin_dir"samtools" mpileup -B -Q 0 -R -d $max -f $path_gen".fasta" - | awk '$4 > '$min > $nome".mpileup"


###calling INDEL 

echo "INDEL (VarScan):" > $nome"_stat"

java -Xmx2g -jar $bin_dir"VarScan.v2.3.7.jar" pileup2indel $nome".mpileup" --min-coverage $min --min-avg-qual $min_qual --min-reads2 $min_all --p-value 0.05 | awk '{if (NR!=1) {print $1"\t"$2"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"}}' | $bin_dir"bedtools/bedtools" intersect -a stdin -b $BED_in -f 1 > $nome"_indel.varscan"

wc -l $nome"_indel.varscan" >> $nome"_stat"

#position sequenced

rm $nome"_temp.BED"

cut -f2 $nome".mpileup" > $nome"_temp.pos"
start=$(head -1 $nome"_temp.pos")
minus=$(( $start - 1 ))
prev=$(( $start - 1 ))

#take name from chromosome BED file
ch_name=$(tail -1 $scaffold | cut -f1)

while read line
do
  #echo $line $minus $prev $start $end
  minus=$(( $line - 1 ))  
  if [ $minus != $prev ]; then
    end=$prev
    echo -e $ch_name"\t"$start"\t"$end >> $nome"_temp.BED"    
    start=$line
  fi  
  prev=$line  
  #echo $line $minus $prev $start $end  
done < $nome"_temp.pos"

echo -e $ch_name"\t"$start"\t"$(tail -1 $nome"_temp.pos") >> $nome"_temp.BED"

$bin_dir"bedtools/bedtools" sort -i  $nome"_temp.BED" | $bin_dir"bedtools/bedtools" intersect -a stdin -b $BED_in > $nome"_tot.BED"



###filtering popoolation
echo "start mpileup filetring (Popool)"

##find indel region
perl $bin_dir"basic-pipeline/identify-genomic-indel-regions.pl" --input $nome".mpileup" --output $nome"_indel.gtf"

#add indel region with repeated regions
cat $masked_rep $nome"_indel.gtf" > $nome"_repindel.gtf"

perl $bin_dir"basic-pipeline/filter-pileup-by-gtf.pl" --gtf $nome"_repindel.gtf" --input $nome".mpileup" --output $nome"_filt.mpileup"

echo "finish mpileup filetring (Popool)"


#position sequenced
rm $nome"_temp.BED"

cut -f2 $nome"_filt.mpileup" > $nome"_temp.pos"
start=$(head -1 $nome"_temp.pos")
minus=$(( $start - 1 ))
prev=$(( $start - 1 ))

#take name from chromosome BED file
ch_name=$(tail -1 $scaffold | cut -f1)

while read line
do
  #echo $line $minus $prev $start $end
  minus=$(( $line - 1 ))  
  if [ $minus != $prev ]; then
    end=$prev
    echo -e $ch_name"\t"$start"\t"$end >> $nome"_temp.BED"    
    start=$line
  fi  
  prev=$line  
  #echo $line $minus $prev $start $end  
done < $nome"_temp.pos"

echo -e $ch_name"\t"$start"\t"$(tail -1 $nome"_temp.pos") >> $nome"_temp.BED"

$bin_dir"bedtools/bedtools" sort -i  $nome"_temp.BED" | $bin_dir"bedtools/bedtools" intersect -a stdin -b $BED_in > $nome"_filt.BED"

wc -l $nome".mpileup" >> $nome"_stat"
wc -l $nome"_filt.mpileup" >> $nome"_stat"


echo "start SNP calling (NPstat, Snape) on filtered mpileup"

###NPStat to get theta and divergence
$bin_dir"npstat2" -n $chr_pool -l $l_npstat -mincov $min -maxcov $max -minqual $min_qual -nolowfreq $min_all -outgroup $scaffold_fa $nome"_filt.mpileup"

awk '$2!=0' $nome"_filt.mpileup.stats" > $nome".stats"

theta=$(awk '{sum+=$6} END { print sum/NR}' $nome".stats")
D=$(awk '{sum+=$13} END { print sum/NR}' $nome".stats")
echo "#Chromosomes $nome, theta is $theta, D is $D" >> $nome"_stat"
rm $nome"_filt.mpileup.stats"
rm $nome".stats"




##snape
echo "Snape:" >> $nome"_stat"

$bin_dir"snape-pooled" -nchr $chr_pool -theta $theta -D $D -fold unfolded -priortype informative < $nome"_filt.mpileup" | awk '$9 > '$pp_snape' && $5 >='$min_all' {print $1"\t"$2"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"}' |$bin_dir"bedtools/bedtools" intersect -a stdin -b $BED_in -f 1 > $nome.snape


wc -l $nome.snape >> $nome"_stat"
#get SNP with nomultiallelic positions and do NPStat statistic only on them
awk '$5!=0 {print $2}' $nome.snape > $nome"_snape.snp"
wc -l $nome"_snape.snp" >> $nome"_stat"

$bin_dir"npstat2" -n $chr_pool -l $l_npstat -mincov $min -maxcov $max -minqual $min_qual -nolowfreq $min_all -outgroup $scaffold_fa -annot $gff3 -snpfile $nome"_snape.snp" $nome"_filt.mpileup"

awk '$2!=0' $nome"_filt.mpileup.stats" > $nome"_snape.npstats"
rm $nome"_filt.mpileup.stats"

theta=$(awk '{sum+=$6} END { print sum/NR}' $nome"_snape.npstats")
D=$(awk '{sum+=$13} END { print sum/NR}' $nome"_snape.npstats")
echo "#Chromosomes $nome, theta is $theta, D is $D" >> $nome"_stat"




echo "VarScan:" >> $nome"_stat"

java -Xmx2g -jar $bin_dir"VarScan.v2.3.7.jar" pileup2snp $nome"_filt.mpileup" --min-coverage $min --min-avg-qual $min_qual --min-reads2 $min_all --p-value 0.05 | awk '{if (NR!=1) {print $1"\t"$2"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"}}' | $bin_dir"bedtools/bedtools" intersect -a stdin -b $BED_in -f 1 > $nome.varscan

wc -l $nome.varscan >> $nome"_stat"
awk '$8!="100%" {print $2}' $nome.varscan > $nome"_varscan.snp"
wc -l $nome"_varscan.snp" >> $nome"_stat"

$bin_dir"npstat2" -n $chr_pool -l $l_npstat -mincov $min -maxcov $max -minqual $min_qual -nolowfreq $min_all -outgroup $scaffold_fa -annot $gff3 -snpfile $nome"_varscan.snp" $nome"_filt.mpileup"

awk '$2!=0' $nome"_filt.mpileup.stats" > $nome"_varscan.npstats"
rm $nome"_filt.mpileup.stats"

theta=$(awk '{sum+=$6} END { print sum/NR}' $nome"_varscan.npstats")
D=$(awk '{sum+=$13} END { print sum/NR}' $nome"_varscan.npstats")
echo "#Chromosomes $nome, theta is $theta, D is $D" >> $nome"_stat"


rm $nome"_varscan.snp"
rm $nome"_snape.snp"
rm $nome"_filt.mpileup.params"
rm $nome"_filt.mpileup"
rm $nome".mpileup.params"
rm $nome.mpileup
#rm $nome.bam
#rm $nome"_row.bam"
rm $nome"_indel.gtf"
rm $nome"_indel.gtf.params"
rm $nome"_repindel.gtf"
rm $nome"_temp.pos"
rm $nome"_temp.BED"
rm $nome"_temp2.BED"
