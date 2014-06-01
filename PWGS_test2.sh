#! /bin/bash

###############################################################################

##INPUT

bin_dir="/home/fracassettim/pipe_bin/"
path_gen="/scratch/fracassettim/Genome_Alyrata/"
n_threads=2

scaf_tot=(list_scaffold1 list_scaffold2 list_scaffold3 list_scaffold4 list_scaffold5 list_scaffold6 list_scaffold7 list_scaffold8 list_scaffold9_1118)

scaf_num=(1 2 3 4 5 6 7 8 9_1118)


nome_gen="test"
#nome_gen="p11U"
bam_in="test.bam"

min=4 #should be at least 4
#min=25 #should be at least 4
max=500
min_qual=20
chr_pool=50
theta=0.01
D=0.01



#############################################################################

mkdir $nome_gen"_SNP_scaf"




i=0
len=${#scaf_tot[*]}
while [ $i -lt $len ]; do
echo "$i: ${scaf_tot[$i]}"

  qsub -v min="$min",max="$max",min_qual="$min_qual",chr_pool="$chr_pool",theta="$theta",D="$D",n_threads="$n_threads",bam_in="$bam_in",scaffold=${scaf_tot[$i]},nome=$nome_gen"_SNP_scaf/scaf"${scaf_num[$i]} -pe smp $n_threads -o $nome_gen"_"${scaf_num[$i]}"_worker2.out" -hold_jid $nome"_PWGS_mergebam" -N $nome"worker2" PWGS_worker2.sh

let i++
done



