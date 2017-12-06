#!/bin/bash
if [ "$#" -ne 2 ] 
then
  echo "Usage: $0 inputFile compiler"
  exit 1
fi

nloops=5
np=`grep -c ^processor /proc/cpuinfo`


rm -f openMpResult.txt
for i in  `seq 1 $np`; do
    export OMP_NUM_THREADS=$i
    for j in  `seq 1 $nloops`; do
        echo number of threads: $i, run number: $j 
        p6 $1 | grep finish >>  openMpResult.txt
    done
done

mkdir -p ../../../plots/PureShareMemory/$(hostname)/$2
cat openMpResult.txt | awk '{}{print $6, $3}{}' | awk '{Prod[$1]++; min[$1]=Prod[$1]==1||min[$1]>$2?$2:min[$1]} END{ for (var in Prod) printf "%s threads: the min is %f\n", var,min[var]}'  | sort -n  > ../../../plots/PureShareMemory/$(hostname)/$2/p6_OpenMP.txt

rm openMpResult.txt
#rm RunHistory.dat

