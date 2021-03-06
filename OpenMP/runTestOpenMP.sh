#!/bin/bash
if [ "$#" -ne 2 ] 
then
  echo "Usage: $0 numberOfIterations  compiler"
  exit 1
fi

tempFilename='anyTempFileNameWillWork.txt'

outputFilename='laplace_OpenMP.txt'

nloops=5
npt=`grep -c ^processor /proc/cpuinfo`
np="$(($npt / 1))"

rm -f $tempFilename

for i in  `seq 1 $np`; do
    export OMP_NUM_THREADS=$i
    for j in  `seq 1 $nloops`; do
        echo number of threads: $i, run number: $j 
        ./laplace_OpenMP $1 | grep Total >>  $tempFilename
    done
done

mkdir -p ../../plots/$(hostname)/$2

cat $tempFilename | awk 'BEGIN{} {print $4,$10, $13, $14} END{}' | awk '{Prod[$2]++; min[$2]=Prod[$2]==1||min[$2]>$4?$4:min[$2]} END{ for (var in Prod) printf "%s threads: the min is %f\n", var,min[var]}' | sort -n  > ../../plots/$(hostname)/$2/$outputFilename

rm $tempFilename

