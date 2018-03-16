#!/bin/bash
if [ "$#" -ne 2 ]
then
  echo "Usage: $0 numberOfIterations  compiler"
  exit 1
fi

tempFilename='anyTempFileNameWillWork.txt'

outputFilename='laplace_MPI+MPI.txt'

nloops=5
npt=`grep -c ^processor /proc/cpuinfo`
np="$(($npt / 1))"
npps="$(($np / 2))"
npm1="$(($np - 1))"

sequence=''
##########################################
for i in  `seq 0 $((npps-1))`; do
    sequence+=$i','
    sequence+=$(($i +  $((np/2))  ))','
done
##########################################
#for i in `seq 0 $((npm1))`; do
#    sequence+=$i','
#done
##########################################
#for i in `seq 0 2 $((npm1))`; do
#    sequence+=$i','
#done
#for i in `seq 1 2 $((npm1))`; do
#    sequence+=$i','
#done
##########################################

sequence=${sequence%?}
echo $sequence

if [ -n "$LM_LICENSE_FILE" ]; then
    echo "Pgi Compiler"
elif [ -n "$INTEL_LICENSE_FILE" ]; then
    echo "Intel Compiler"
else
    echo "Gnu Compiler"
fi  


rm -f $tempFilename

for i in  `seq 1 $np`; do
#for i in  1 4 `seq 4  4 $np`; do

    for j in  `seq 1 $nloops`; do
        echo number of processors: $i, run number: $j
        mpiexec -n $i laplace_MPI+MPI  $1 | grep Total >>  $tempFilename
        #aprun -n $i laplace_MPI+MPI  $1 | grep Total >>  $tempFilename
    done
done

mkdir -p ../../plots/$(hostname)/$2

cat $tempFilename | awk 'BEGIN{} {print $4,$6, $11, $17} END{}' | awk '{Prod[$2]++; min[$2]=Prod[$2]==1||min[$2]>$4?$4:min[$2]} END{ for (var in Prod) printf "%s processors: the min is %f\n", var,min[var]}' | sort -n  > ../../plots/$(hostname)/$2/$outputFilename

rm $tempFilename

