#! /bin/bash

###############################################################################

##INPUT

bin_dir="/scicore/home/williy/fracasse/pipe_bin/"
path_gen="/scicore/home/williy/fracasse/Genome/lyrata_ref_masked"
masked_rep="/scicore/home/williy/fracasse/Genome/Alyrata_18_P_thaliana.fasta.out.gff"
n_threads=1

scaf_tot=(/scicore/home/williy/fracasse/Genome/list_scaffold1 /scicore/home/williy/fracasse/Genome/list_scaffold2 /scicore/home/williy/fracasse/Genome/list_scaffold3 /scicore/home/williy/fracasse/Genome/list_scaffold4 /scicore/home/williy/fracasse/Genome/list_scaffold5 /scicore/home/williy/fracasse/Genome/list_scaffold6 /scicore/home/williy/fracasse/Genome/list_scaffold7 /scicore/home/williy/fracasse/Genome/list_scaffold8)

scaf_num=(scaffold_1 scaffold_2 scaffold_3 scaffold_4 scaffold_5 scaffold_6 scaffold_7 scaffold_8)

scaf_fa=(/scicore/home/williy/fracasse/Genome/lyr_th_scaf/scaffold_1_th.fa /scicore/home/williy/fracasse/Genome/lyr_th_scaf/scaffold_2_th.fa /scicore/home/williy/fracasse/Genome/lyr_th_scaf/scaffold_3_th.fa /scicore/home/williy/fracasse/Genome/lyr_th_scaf/scaffold_4_th.fa /scicore/home/williy/fracasse/Genome/lyr_th_scaf/scaffold_5_th.fa /scicore/home/williy/fracasse/Genome/lyr_th_scaf/scaffold_6_th.fa /scicore/home/williy/fracasse/Genome/lyr_th_scaf/scaffold_7_th.fa /scicore/home/williy/fracasse/Genome/lyr_th_scaf/scaffold_8_th.fa)

gff3=(/scicore/home/williy/fracasse/Genome/Alyr_v2_CDS_s1.gff /scicore/home/williy/fracasse/Genome/Alyr_v2_CDS_s2.gff /scicore/home/williy/fracasse/Genome/Alyr_v2_CDS_s3.gff /scicore/home/williy/fracasse/Genome/Alyr_v2_CDS_s4.gff /scicore/home/williy/fracasse/Genome/Alyr_v2_CDS_s5.gff /scicore/home/williy/fracasse/Genome/Alyr_v2_CDS_s6.gff /scicore/home/williy/fracasse/Genome/Alyr_v2_CDS_s7.gff /scicore/home/williy/fracasse/Genome/Alyr_v2_CDS_s8.gff)




#bam_in="test_Nuc.bam"
#bam_in="/scicore/home/williy/fracasse/bam_ALL/pop07C/p07C_Nuc.bam"


#min=4 #should be at least 4
min=50 #should be at least 4
max=500
min_qual=20
chr_pool=50
l_npstat=5000

min_all=3
nolowfreq=2
pv_varscan=0.15
min_freq_varscan=0.03


module load SAMtools/0.1.19-goolf-1.4.10
module load BEDTools/2.25.0-goolf-1.4.10
module load GSL/1.16-goolf-1.4.10

fold_pops=(07C 07D 07E 07F 07G 07J 07K 07L 07M 07N 07O 07P 07Q 07R 11C 11AA 11AB 11AC 11AE 11AG 11AH 11AJ 11B 11G 11H 11J 11K 11L_F0  11M 11N 11O 11P 11Q 11S 11T 11U 11W 11X 11Z 11D 11V 11R 11A 11E 11F 11Y 14A 14B 14C 14D 14E 07H Ha31)

#fold_pops=(11A 11F 11Y 14A)

folder1="/scicore/home/williy/GROUP/bam_ALL/"


j=0
len_pop=${#fold_pops[*]}
while [ $j -lt $len_pop ]; do
  bam_in=$folder1"pop"${fold_pops[$j]}"/p"${fold_pops[$j]}"_Nuc.bam"
  echo $bam_in

  #############################################################################

  nome="p"${fold_pops[$j]}"_tot"
  BED_in="/scicore/home/williy/fracasse/Genome/scaffolds_18.BED"
  mkdir $nome"_SNP_scaf"
  i=0
  len=${#scaf_tot[*]}
  while [ $i -lt $len ]; do
    qsub -v min=$min,max=$max,min_qual=$min_qual,chr_pool=$chr_pool,bam_in=$bam_in,scaffold=${scaf_tot[$i]},nome=$nome"_SNP_scaf/"${scaf_num[$i]},l_npstat=$l_npstat,scaffold_fa=${scaf_fa[$i]},path_gen=$path_gen,min_all=$min_all,nolowfreq=$nolowfreq,pv_varscan=$pv_varscan,min_freq_varscan=$min_freq_varscan,bin_dir=$bin_dir,masked_rep=$masked_rep,gff3=${gff3[$i]},BED_in=$BED_in -pe smp $n_threads -o $nome"_"${scaf_num[$i]}"_SNPcall.out" -N $nome"_"${scaf_num[$i]}"_SNPcall" PWGS_SNPcall_Varscan_BAS.sh
    
  let i++
  done
  
  #############################################################################

  nome="p"${fold_pops[$j]}"_intergenic_1000bp"
  BED_in="/scicore/home/williy/fracasse/Genome/intergenic_v2_1000bp.BED"
  
  mkdir $nome"_SNP_scaf"
  i=0
  len=${#scaf_tot[*]}
  while [ $i -lt $len ]; do
    qsub -v min=$min,max=$max,min_qual=$min_qual,chr_pool=$chr_pool,bam_in=$bam_in,scaffold=${scaf_tot[$i]},nome=$nome"_SNP_scaf/"${scaf_num[$i]},l_npstat=$l_npstat,scaffold_fa=${scaf_fa[$i]},path_gen=$path_gen,min_all=$min_all,nolowfreq=$nolowfreq,pv_varscan=$pv_varscan,min_freq_varscan=$min_freq_varscan,bin_dir=$bin_dir,masked_rep=$masked_rep,gff3=${gff3[$i]},BED_in=$BED_in -pe smp $n_threads -o $nome"_"${scaf_num[$i]}"_SNPcall.out" -N $nome"_"${scaf_num[$i]}"_SNPcall" PWGS_SNPcall_Varscan_BAS.sh
    
  let i++
  done
  
  #############################################################################
  
  nome="p"${fold_pops[$j]}"_CDS"
  BED_in="/scicore/home/williy/fracasse/Genome/CDS_v2.BED"
  
  mkdir $nome"_SNP_scaf"
  i=0
  len=${#scaf_tot[*]}
  while [ $i -lt $len ]; do
    qsub -v min=$min,max=$max,min_qual=$min_qual,chr_pool=$chr_pool,bam_in=$bam_in,scaffold=${scaf_tot[$i]},nome=$nome"_SNP_scaf/"${scaf_num[$i]},l_npstat=$l_npstat,scaffold_fa=${scaf_fa[$i]},path_gen=$path_gen,min_all=$min_all,nolowfreq=$nolowfreq,pv_varscan=$pv_varscan,min_freq_varscan=$min_freq_varscan,bin_dir=$bin_dir,masked_rep=$masked_rep,gff3=${gff3[$i]},BED_in=$BED_in -pe smp $n_threads -o $nome"_"${scaf_num[$i]}"_SNPcall.out" -N $nome"_"${scaf_num[$i]}"_SNPcall" PWGS_SNPcall_Varscan_BAS.sh
    
  let i++
  done
  
  #############################################################################
  
  nome="p"${fold_pops[$j]}"_intron"
  BED_in="/scicore/home/williy/fracasse/Genome/intron_v2.BED"
  
  mkdir $nome"_SNP_scaf"
  i=0
  len=${#scaf_tot[*]}
  while [ $i -lt $len ]; do
    qsub -v min=$min,max=$max,min_qual=$min_qual,chr_pool=$chr_pool,bam_in=$bam_in,scaffold=${scaf_tot[$i]},nome=$nome"_SNP_scaf/"${scaf_num[$i]},l_npstat=$l_npstat,scaffold_fa=${scaf_fa[$i]},path_gen=$path_gen,min_all=$min_all,nolowfreq=$nolowfreq,pv_varscan=$pv_varscan,min_freq_varscan=$min_freq_varscan,bin_dir=$bin_dir,masked_rep=$masked_rep,gff3=${gff3[$i]},BED_in=$BED_in -pe smp $n_threads -o $nome"_"${scaf_num[$i]}"_SNPcall.out" -N $nome"_"${scaf_num[$i]}"_SNPcall" PWGS_SNPcall_Varscan_BAS.sh
    
  let i++
  done

  #############################################################################
  
let j++
done






