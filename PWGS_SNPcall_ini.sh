#! /bin/bash

###############################################################################

##INPUT

bin_dir="/scratch/fracassettim/pipe_bin/"
path_gen="/scratch/fracassettim/Genomes/Alyrata_18_P_thaliana"
n_threads=2

scaf_tot=(/scratch/fracassettim/Genomes/list_scaffold1 /scratch/fracassettim/Genomes/list_scaffold2 /scratch/fracassettim/Genomes/list_scaffold3 /scratch/fracassettim/Genomes/list_scaffold4 /scratch/fracassettim/Genomes/list_scaffold5 /scratch/fracassettim/Genomes/list_scaffold6 /scratch/fracassettim/Genomes/list_scaffold7 /scratch/fracassettim/Genomes/list_scaffold8)

scaf_num=(1 2 3 4 5 6 7 8)

scaf_fa=(_split/scaffold_1.fa _split/scaffold_2.fa _split/scaffold_3.fa _split/scaffold_4.fa _split/scaffold_5.fa _split/scaffold_6.fa _split/scaffold_7.fa _split/scaffold_8.fa)

nome="test"

bam_in="test_Nuc.bam"

min=4 #should be at least 4
#min=25 #should be at least 4
max=500
min_qual=20
chr_pool=50
l_npstat=1000




#############################################################################

mkdir $nome"_SNP_scaf"


i=0
len=${#scaf_tot[*]}
while [ $i -lt $len ]; do
  echo "$i: ${scaf_tot[$i]}"
  qsub -v min=$min,max=$max,min_qual=$min_qual,chr_pool=$chr_pool,bam_in=$bam_in,scaffold=${scaf_tot[$i]},nome=$nome"_SNP_scaf/scaf"${scaf_num[$i]},l_npstat=$l_npstat,scaffold_fa=${scaf_fa[$i]},path_gen=$path_gen -pe smp $n_threads -o $nome"_"${scaf_num[$i]}"_SNPcall.out" -hold_jid $nome"_PWGS_filtmerge" -N $nome"_SNPcall" PWGS_SNPcall.sh
  
  
let i++
done



