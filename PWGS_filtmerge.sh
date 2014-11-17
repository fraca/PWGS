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

nome="bla_filtmerge_$nome2"

echo "########################################" > $nome2"_cov"
echo "########################################" >> $nome2"_cov"
echo "Population $nome2" >> $nome2"_cov"
echo "########################################" >> $nome2"_cov"
echo -e "########################################\n" >> $nome2"_cov"




array=(`echo ${unicum//-/ } ` )

i=0
len=${#array[*]}

if [ "$len" -eq 1 ]; then
  mv ${array[$i]}".bam" $nome".bam"
else
  unicum_bam=$(echo ${unicum//-/.bam })
  $bin_dir"samtools" merge -@ $n_threads -f $nome".bam" $unicum_bam
fi



while [ $i -lt $len ]; do
  echo "$i: ${array[$i]}" >> $nome2"_cov"
  tail -8 ${array[$i]}_mystat >> $nome2"_cov"
  rm ${array[$i]}_mystat
  echo -e "#######\n\n" >> $nome2"_cov"
  rm ${array[$i]}".bam" 
  rm ${array[$i]}".bam.bai"
let i++
done


echo "########################################" >> $nome2"_cov"
echo -e "All lane merged\n" >> $nome2"_cov"

echo 'Total reads filtered' >> $nome2"_cov"
$bin_dir"samtools" view -c $nome".bam" >> $nome2"_cov"

#####################################################################
###removing duplicate
#####################################################################

java -Xmx2g -jar $bin_dir"SortSam.jar" I=$nome".bam" O=$nome"_sort.bam" VALIDATION_STRINGENCY=SILENT SO=coordinate

java -Xmx2g -jar $bin_dir"MarkDuplicates.jar" I=$nome"_sort.bam" O=$nome"_rd.bam" M=$nome"_dupstat.txt" VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true

echo 'reads after picard MarkDuplicates' >> $nome2"_cov"
$bin_dir"samtools" view  -c $nome"_rd.bam" >> $nome2"_cov"

#####################################################################
##dividing bam file based on bed files
#####################################################################

echo -e '\nGenome covered & read depth\n' >> $nome2"_cov"

un_array_bed=(`echo ${un_array_bed//-/ } ` )
un_nome_bed=(`echo ${un_nome_bed//-/ } ` )

j=0
lon=${#un_array_bed[*]}
while [ $j -lt $lon ]; do
  $bin_dir"samtools" view -@ $n_threads -L ${un_array_bed[$j]} $nome"_rd.bam" -b > $nome2"_"${un_nome_bed[$j]}.bam
  $bin_dir"samtools" index $nome2"_"${un_nome_bed[$j]}.bam
  
  $bin_dir"/bedtools/genomeCoverageBed" -ibam $nome2"_"${un_nome_bed[$j]}.bam > $nome2"_"${un_nome_bed[$j]}"_bedtools"  
  grep "^genome" $nome2"_"${un_nome_bed[$j]}"_bedtools" |  awk ' {if($2>='$min' && $2<='$max') {{bla+=$5; mpond+=$2*$3; sum+=$3}}} END { print "'${un_nome_bed[$j]}': (cov min-max '$min'-'$max') genome covered",bla,"% mean read depth",mpond/sum}' >> $nome2"_cov"
  
  i=0
  cut -f1 ${un_array_bed[$j]} | sed 1d > $nome.nonso
  IFS=$'\r\n' GLOBIGNORE='*' :; scafs=($(cat $nome.nonso))
  
  len=${#scafs[*]}
  while [ $i -lt $len ]; do
    grep -P "^"${scafs[$i]}"\t" $nome2"_"${un_nome_bed[$j]}"_bedtools" |  awk ' {if($2>='$min' && $2<='$max') {{bla+=$5; mpond+=$2*$3; sum+=$3}}} END { print " '${scafs[$i]}': (cov min-max '$min'-'$max') genome covered",bla,"% mean read depth",mpond/sum}' >> $nome2"_cov"  
  let i++
  done
  
let j++
done

echo -e '\n' >> $nome2"_cov"
rm "$nome"*
