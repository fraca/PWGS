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

bin_dir="/scratch/fracassettim/pipe_bin/"

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
  samtools merge -@ $n_threads -f $nome".bam" $unicum_bam
fi


while [ $i -lt $len ]; do
  echo "$i: ${array[$i]}" >> $nome2"_cov"
  head -7 ${array[$i]}_mystat >> $nome2"_cov"
  rm ${array[$i]}_mystat
  echo -e "#######\n\n" >> $nome2"_cov"
  rm ${array[$i]}".bam"
let i++
done




echo "########################################" >> $nome2"_cov"
echo -e "All lane merged\n" >> $nome2"_cov"

echo 'Total reads filtered' >> $nome2"_cov"
samtools view -c $nome".bam" >> $nome2"_cov"

#####################################################################
###removing duplicate
#####################################################################

java -Xmx2g -jar $bin_dir"SortSam.jar" I=$nome".bam" O=$nome"_sort.bam" VALIDATION_STRINGENCY=SILENT SO=coordinate

java -Xmx2g -jar $bin_dir"MarkDuplicates.jar" I=$nome"_sort.bam" O=$nome"_rd.bam" M=$nome"_dupstat.txt" VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true

echo 'reads after picard MarkDuplicates' >> $nome2"_cov"
samtools view  -c $nome"_rd.bam" >> $nome2"_cov"

#####################################################################
###Filtering mapped reads only in 1-8 scaffold
#####################################################################

samtools view -@ $n_threads -L $path_gen"_list_Nuclear" $nome"_rd.bam" -b > $nome"_rd_Nuclear.bam"


samtools view -@ $n_threads -q $alg_qual -f 0x0002 -F 0x0004 -F 0x0008 -b $nome"_rd_Nuclear.bam" > $nome2"_filt.bam"
samtools index $nome2"_filt.bam"

echo 'reads in the nuclear genome filtered' >> $nome2"_cov"

samtools view -c $nome2"_filt.bam" >> $nome2"_cov"

#echo -e 'scaffold\tbp_length\tn_reads' >> $nome2"_cov"
#samtools idxstats $nome2"_filt.bam" >> $nome2"_cov"

$bin_dir"/bedtools/genomeCoverageBed" -ibam $nome2"_filt.bam" > $nome2"_bedtools"


echo -e 'Genome covered & read depth\n' >> $nome2"_cov"

awk '$1 !~/#/ {print $1}' $path_gen"_list_Nuclear" > $nome"_temp"
declare -a scafs
readarray -t scafs < $nome"_temp" # Exclude newline.

i=0
len=${#scafs[*]}
while [ $i -lt $len ]; do
  grep -P "^"${scafs[$i]}"\t" $nome2"_bedtools" |  awk ' {if($2>='$min' && $2<='$max') {{bla+=$5; mpond+=$2*$3; sum+=$3}}} END { print " '${scafs[$i]}' (cov min-max '$min'-'$max') genome covered",bla,"% mean read depth",mpond/sum}' >> $nome2"_cov"

  
let i++
done

grep "^genome" $nome2"_bedtools" |  awk ' {if($2>='$min' && $2<='$max') {{bla+=$5; mpond+=$2*$3; sum+=$3}}} END { print "Total: (cov min-max '$min'-'$max') genome covered",bla,"% mean read depth",mpond/sum}' >> $nome2"_cov"


rm "$nome"*

