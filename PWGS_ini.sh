#! /bin/bash

###############################################################################

##INPUT

bin_dir="/scratch/fracassettim/pipe_bin/"
path_gen="/scratch/fracassettim/Genomes/Alyrata_18_P_thaliana"

n_threads=2 


array_R1=(lane_input/L3a_R1.fq.gz  lane_input/L3b_R1.fq.gz  lane_input/L4a_R1.fq.gz  lane_input/L4b_R1.fq.gz)
array_R2=(lane_input/L3a_R2.fq.gz  lane_input/L3b_R2.fq.gz  lane_input/L4a_R2.fq.gz  lane_input/L4b_R2.fq.gz)
array_name=(L3a  L3b  L4a  L4b)
array_bed=( /scratch/fracassettim/Genomes/Alyrata_18_P_thaliana_list_Nuclear /scratch/fracassettim/Genomes/Alyrata_18_P_thaliana_list_Plastid /scratch/fracassettim/Genomes/list_scaffold1 )
nome_bed=( Nuc Pla prova1 )
nome="test"


min=1 
max=500
min_qual=20
alg_qual=20

#############################################################################

i=0
len=${#array_R1[*]}
while [ $i -lt $len ]; do
  echo "$i: ${array_name[$i]}"

  qsub -v n_threads=$n_threads,min_qual=$min_qual,lane1=${array_R1[$i]},lane2=${array_R2[$i]},nome2=${array_name[$i]},path_gen=$path_gen,bin_dir=$bin_dir -pe smp $n_threads -o $nome"_"${array_name[$i]}"_paired.out" -N $nome"_PWGS_paired" PWGS_paired.sh

let i++
done



unicum=$(echo ${array_name[@]})
unicum=$(echo ${unicum// /-}-)
un_array_bed=$(echo ${array_bed[@]})
un_array_bed=$(echo ${un_array_bed// /-}-)
un_nome_bed=$(echo ${nome_bed[@]})
un_nome_bed=$(echo ${un_nome_bed// /-}-)

#echo $unicum
#echo $un_array_bed
#echo $un_nome_bed

qsub -v n_threads=$n_threads,alg_qual="$alg_qual",min="$min",max="$max",nome2="$nome",unicum=$unicum,path_gen=$path_gen,un_array_bed=$un_array_bed,un_nome_bed=$un_nome_bed,bin_dir=$bin_dir -pe smp $n_threads -o $nome"_filtmerge.out" -hold_jid $nome"_PWGS_paired" -N $nome"_PWGS_filtmerge" PWGS_filtmerge.sh





