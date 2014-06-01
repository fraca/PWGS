#! /bin/bash

###############################################################################

##INPUT

bin_dir="/home/fracassettim/pipe_bin/"
path_gen="/scratch/fracassettim/Genome_Alyrata/"
n_threads=5 


array_R1=(lane_input/L3a_R1.fq.gz  lane_input/L3b_R1.fq.gz  lane_input/L4a_R1.fq.gz  lane_input/L4b_R1.fq.gz)
array_R2=(lane_input/L3a_R2.fq.gz  lane_input/L3b_R2.fq.gz  lane_input/L4a_R2.fq.gz  lane_input/L4b_R2.fq.gz)
array_name=(L3a  L3b  L4a  L4b)
nome="test"


min=4 #should be at least 4
max=500
min_qual=20
chr_pool=50

#############################################################################

i=0
len=${#array_R1[*]}
while [ $i -lt $len ]; do
echo "$i: ${array_name[$i]}"

qsub -v n_threads="$n_threads",min_qual="$min_qual",lane1=${array_R1[$i]},lane2=${array_R2[$i]},nome2=${array_name[$i]} -pe smp $n_threads -o $nome"_"${array_name[$i]}".out" -N $nome"_PWGS_worker" PWGS_worker.sh

let i++
done



unicum=$( echo ${array_name[@]})

unicum=$(echo ${unicum// /-}-)


qsub -v n_threads=$((n_threads*4)),min="$min",max="$max",nome2="$nome",unicum=$unicum -pe smp $((n_threads*4)) -o $nome"_mergebam.out" -hold_jid $nome"_PWGS_worker" -N $nome"_PWGS_mergebam" PWGS_mergebam.sh





