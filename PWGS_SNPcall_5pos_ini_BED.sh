#! /bin/bash

###############################################################################

##INPUT

bin_dir="/scratch/fracassettim/pipe_bin/"
path_gen="/scratch/fracassettim/Genomes/Alyrata_18_P_thaliana"
masked_rep="/scratch/fracassettim/Genomes/Alyrata_18_P_thaliana.fasta.out.gff"
n_threads=1

scaf_tot=(/scratch/fracassettim/Genomes/list_scaffold1 /scratch/fracassettim/Genomes/list_scaffold2 /scratch/fracassettim/Genomes/list_scaffold3 /scratch/fracassettim/Genomes/list_scaffold4 /scratch/fracassettim/Genomes/list_scaffold5 /scratch/fracassettim/Genomes/list_scaffold6 /scratch/fracassettim/Genomes/list_scaffold7 /scratch/fracassettim/Genomes/list_scaffold8)

scaf_num=(scaffold_1 scaffold_2 scaffold_3 scaffold_4 scaffold_5 scaffold_6 scaffold_7 scaffold_8)

scaf_fa=(/scratch/fracassettim/Genomes/lyr_th_scaf/scaffold_1_th.fa /scratch/fracassettim/Genomes/lyr_th_scaf/scaffold_2_th.fa /scratch/fracassettim/Genomes/lyr_th_scaf/scaffold_3_th.fa /scratch/fracassettim/Genomes/lyr_th_scaf/scaffold_4_th.fa /scratch/fracassettim/Genomes/lyr_th_scaf/scaffold_5_th.fa /scratch/fracassettim/Genomes/lyr_th_scaf/scaffold_6_th.fa /scratch/fracassettim/Genomes/lyr_th_scaf/scaffold_7_th.fa /scratch/fracassettim/Genomes/lyr_th_scaf/scaffold_8_th.fa)

gff3="/scratch/fracassettim/Genomes/Alyrata_v28_scaf18.gff3"


nome="test"

bam_in="test_Nuc.bam"
BED_in="/scratch/fracassettim/Genomes/Genes_v28.BED"

min=4 #should be at least 4
#min=25 #should be at least 4
max=500
min_qual=20
chr_pool=50
l_npstat=1000
min_all=2 
pp_snape=0.9


#############################################################################

mkdir $nome"_SNP_scaf"


i=0
len=${#scaf_tot[*]}
while [ $i -lt $len ]; do
  echo "$i: ${scaf_tot[$i]}"
  qsub -v min=$min,max=$max,min_qual=$min_qual,chr_pool=$chr_pool,bam_in=$bam_in,scaffold=${scaf_tot[$i]},nome=$nome"_SNP_scaf/"${scaf_num[$i]},l_npstat=$l_npstat,scaffold_fa=${scaf_fa[$i]},path_gen=$path_gen,min_all=$min_all,pp_snape=$pp_snape,bin_dir=$bin_dir,masked_rep=$masked_rep,gff3=$gff3,BED_in=$BED_in -pe smp $n_threads -o $nome"_SNPcall.out" -hold_jid $nome"_PWGS_filtmerge" -N $nome"_SNPcall" PWGS_SNPcall_5pos_BED.sh
  
  
let i++
done



