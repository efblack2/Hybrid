#!/bin/bash
if [ "$#" -ne 3 ] 
then
  echo "Usage: $0  programName numberOfIterations  compiler"
  exit 1
fi

tempFilename='anyTempFileNameWillWork.txt'

program=$1
outputFilename=$program'.txt'

#echo $program
#echo $outputFilename

nloops=5
np=`grep -c ^processor /proc/cpuinfo`

rm -f $tempFilename

for i in  `seq 1 $np`; do
    for j in  `seq 1 $nloops`; do
        echo number of processors: $i, run number: $j 
        mpiexec -n $i $program $2 | grep Total >>  $tempFilename
    done
done

mkdir -p ../../plots/MPI+MPI/$(hostname)/$3

cat $tempFilename | awk 'BEGIN{} {print $4,$6, $11, $17} END{}' | awk '{Prod[$2]++; min[$2]=Prod[$2]==1||min[$2]>$4?$4:min[$2]} END{ for (var in Prod) printf "%s processors: the min is %f\n", var,min[var]}' | sort -n  > ../../plots/MPI+MPI/$(hostname)/$3/$outputFilename

rm $tempFilename

