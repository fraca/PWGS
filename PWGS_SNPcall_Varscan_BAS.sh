#! /bin/bash

# Request "/bin/bash" as shell
#$ -S /bin/bash

# Start the job from the current working directory
#$ -cwd

# Merge standard output and standard error
#$ -j y

#  how much memory? DEFAULT = 2G 
########################
#$ -l membycore=4G

###############################################################################


# to load gsl library fro NPStat

module load R/3.2.4-goolf-1.7.20
module load SAMtools/0.1.19-goolf-1.4.10
module load BEDTools/2.25.0-goolf-1.4.10
module load GSL/1.16-goolf-1.4.10


#non lasciare spazio
nome2=$TMPDIR"/ciao"

#select one scaffold, filter based to BED
#mpileup and filtering coverage, remove N, multiallelic positions, SNP different from reference
samtools view -b -L $scaffold $bam_in | bedtools intersect -abam stdin -b $BED_in | samtools mpileup -B -Q 0 -R -d $max -f $path_gen".fasta" - | awk '$4 > '$min | awk '$4 < '$max  > $nome2".mpileup"


#position sequenced

rm $nome2"_temp.BED"

cut -f2 $nome2".mpileup" > $nome2"_temp.pos"
start=$(head -1 $nome2"_temp.pos")
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
    echo -e $ch_name"\t"$start"\t"$end >> $nome2"_temp.BED"    
    start=$line
  fi  
  prev=$line  
  #echo $line $minus $prev $start $end  
done < $nome2"_temp.pos"

echo -e $ch_name"\t"$start"\t"$(tail -1 $nome2"_temp.pos") >> $nome2"_temp.BED"

bedtools sort -i  $nome2"_temp.BED" | bedtools intersect -a stdin -b $BED_in > $nome"_tot.BED"



###filtering popoolation
echo "start mpileup filetring (Popool)"

##find indel region
perl $bin_dir"basic-pipeline/identify-genomic-indel-regions.pl" --input $nome2".mpileup" --output $nome2"_indel.gtf"

#add indel region with repeated regions
cat $masked_rep $nome2"_indel.gtf" > $nome2"_repindel.gtf"

perl $bin_dir"basic-pipeline/filter-pileup-by-gtf.pl" --gtf $nome2"_repindel.gtf" --input $nome2".mpileup" --output $nome2"_filt.mpileup"
####problema di memoria insufficente qui metti 5GB
echo "finish mpileup filetring (Popool)"


#position sequenced
rm $nome2"_temp.BED"

cut -f2 $nome2"_filt.mpileup" > $nome2"_temp.pos"
start=$(head -1 $nome2"_temp.pos")
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
    echo -e $ch_name"\t"$start"\t"$end >> $nome2"_temp.BED"    
    start=$line
  fi  
  prev=$line  
  #echo $line $minus $prev $start $end  
done < $nome2"_temp.pos"

echo -e $ch_name"\t"$start"\t"$(tail -1 $nome2"_temp.pos") >> $nome2"_temp.BED"

bedtools sort -i  $nome2"_temp.BED" | bedtools intersect -a stdin -b $BED_in > $nome"_filt.BED"

wc -l $nome2".mpileup" >> $nome"_stat"
wc -l $nome2"_filt.mpileup" >> $nome"_stat"

echo "VarScan:" >> $nome"_stat"

java -Xmx2g -jar $bin_dir"VarScan.v2.3.7.jar" pileup2snp $nome2"_filt.mpileup" --min-coverage $min --min-avg-qual $min_qual --min-reads2 $min_all --p-value $pv_varscan --min-var-freq $min_freq_varscan | awk '{if (NR!=1) {print $1"\t"$2"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17"\t"$18"\t"$19"\t"}}' | bedtools intersect -a stdin -b $BED_in -f 1 > $nome.varscan

### il parametro f 1 serve solo se file a sono SNP quindi considera intersezione intera. da lasciare.

wc -l $nome.varscan >> $nome"_stat"
Rscript snp_strand_biall4.R $nome.varscan 
wc -l $nome"_varscan.snp" >> $nome"_stat"


bedtools sort -i $nome".varscan_temp_rem" | bedtools subtract -a $nome"_filt.BED" -b stdin > $nome"_filt2.BED"
rm $nome".varscan_temp_rem"


$bin_dir"npstat" -n $chr_pool -l $l_npstat -mincov $min -maxcov $max -minqual $min_qual -nolowfreq $nolowfreq -outgroup $scaffold_fa -annot $gff3 -snpfile $nome"_varscan.snp" $nome2"_filt.mpileup"


awk '$2!=0' $nome2"_filt.mpileup.stats" > $nome"_varscan.npstats"
rm $nome2"_filt.mpileup.stats"

theta=$(awk '{sum+=$6} END { print sum/NR}' $nome"_varscan.npstats")
D=$(awk '{sum+=$13} END { print sum/NR}' $nome"_varscan.npstats")
echo "#Chromosomes $nome, theta is $theta, D is $D" >> $nome"_stat"
echo "Fine"
##auto remove of file in TEMPDIR
