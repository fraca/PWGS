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

bin_dir="/home/fracassettim/pipe_bin/"
path_gen="/scratch/fracassettim/Genome_Alyrata/"

nome="blabla_$nome2"


#echo "$unicum dentro unicum"

unicum_bam=$(echo ${unicum//-/_filt.bam })

#echo "$unicum_bam dentro unicum_bam"



samtools merge -@ $n_threads -f $nome".bam" $unicum_bam
samtools sort -@ $n_threads $nome".bam" $nome2

samtools index $nome2".bam"



echo -e 'scaffold\tbp_length\tn_reads' >> $nome2"_mystat"
samtools idxstats $nome2".bam" >> $nome2"_mystat"

echo -e 'bedtools coverage' >> $nome2"_mystat"
$bin_dir"/bedtools/genomeCoverageBed" -ibam $nome2".bam" >> $nome2"_mystat"


echo "Population $nome2" > $nome2"_cov"


array=(`echo ${unicum//-/ } ` )
i=0
len=${#array[*]}
while [ $i -lt $len ]; do
  echo "$i: ${array[$i]}" >> $nome2"_cov"
  head -13 ${array[$i]}_mystat >> $nome2"_cov"
  grep "^genome" ${array[$i]}_mystat |  awk ' {if($2>='$min' && $2<='$max') {{bla+=$5; mpond+=$2*$3; sum+=$3}}} END { print "cov min-max '$min'-'$max' genome covered",bla,"% mean coverage",mpond/sum}' >> $nome2"_cov"

  rm ${array[$i]}_filt.bam
  rm ${array[$i]}_filt.bam.bai
  rm ${array[$i]}_mystat
  
let i++
done


echo 'All lanes merged' >> $nome2"_cov"
echo 'Total reads filtered' >> $nome2"_cov"
samtools view -c $nome2".bam" >> $nome2"_cov"

grep "^genome" $nome2"_mystat" |  awk ' {if($2>='$min' && $2<='$max') {{bla+=$5; mpond+=$2*$3; sum+=$3}}} END { print "cov min-max '$min'-'$max' genome covered",bla,"% mean coverage",mpond/sum}' >> $nome2"_cov"




rm "$nome"*

