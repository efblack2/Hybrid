#!/bin/bash
if [ "$#" -ne 2 ]
then
  echo "Usage: $0 numberOfIterations  compiler"
  exit 1
fi

tempFilename='anyTempFileNameWillWork.txt'
outputFilename='laplace_MPI+MPI.txt'

nloops=4

npt=`grep -c ^processor /proc/cpuinfo`
numaNodes=`lscpu | grep "NUMA node(s):" | awk '{}{print $3}{}'`
tpc=`lscpu | grep "Thread(s) per core:" | awk '{}{print $4}{}'`
np="$(($npt / $tpc))"
npps="$(($np / $numaNodes))"
npm1="$(($np - 1))"
tps=$((npps*tpc))


if [ -n "$PGI" ]; then
    echo "Pgi Compiler"
elif [ -n "$INTEL_LICENSE_FILE" ]; then
    echo "Intel Compiler"
else
    echo "Gnu Compiler"
fi

seqArray=()
##########################################
k=0
for i in  `seq 0 $((npps-1))`; do
    kk=$((k))
    for j in `seq 0 $((numaNodes-1))`; do
        seqArray[i*$numaNodes+j]=$((kk))
	kk=$((kk+tps))
    done
    k=$((k+tpc))
done
##########################################

#echo ${seqArray[*]}
sequence=''
for p in `seq 0 $((  npm1  ))`; do
    sequence+=${seqArray[p]}','
done
sequence=${sequence%?}
#echo $sequence

rm -f $tempFilename

for i in 1  `seq 2 2 $np`; do
    for j in  `seq 1 $nloops`; do
        echo number of processors: $i, run number: $j
        aprun -cc $sequence   -n $i -N $i laplace_MPI+MPI  $1 | grep Total >>  $tempFilename
    done
done

mkdir -p ../../plots/$(hostname)/$2

cat $tempFilename | awk 'BEGIN{} {print $4,$6, $11, $17} END{}' | awk '{Prod[$2]++; min[$2]=Prod[$2]==1||min[$2]>$4?$4:min[$2]} END{ for (var in Prod) printf "%s processors: the min is %f\n", var,min[var]}' | sort -n  > ../../plots/$(hostname)/$2/$outputFilename

rm $tempFilename

