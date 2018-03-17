#!/bin/bash
if [ "$#" -ne 2 ]
then
  echo "Usage: $0 numberOfIterations  compiler"
  exit 1
fi

tempFilename='anyTempFileNameWillWork.txt'
outputFilename='laplace_MPI+OpenMP.txt'

nloops=3
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
    export MP_BIND="yes"
    export MP_BLIST=$sequence
    #export MP_BLIST="0-$npm1"
    echo $MP_BLIST
elif [ -n "$INTEL_LICENSE_FILE" ]; then
    echo "Intel Compiler"
    export OMP_PLACES=sockets
    export OMP_PROC_BIND=true
    #export KMP_AFFINITY=scatter
    # needed to use dissabled in Blue waters
    #export KMP_AFFINITY=disabled
else
    echo "Gnu Compiler"
    #export OMP_PLACES=sockets
    #export OMP_PROC_BIND=true
    export GOMP_CPU_AFFINITY=$sequence
    #export GOMP_CPU_AFFINITY="0-$npm1"
fi

rm -f $tempFilename

for i in  1 `seq 2  2 $np`; do
#for i in 1  `seq 4 4  $np`; do
    export OMP_NUM_THREADS=$i
    for j in  `seq 1 $nloops`; do
        echo number of threads: $i, run number: $j
        mpiexec -n 1 laplace_MPI+OpenMP $1 | grep Total >>  $tempFilename
        #aprun -n 1  -N 1 -d $i laplace_MPI+OpenMP $1 | grep Total >>  $tempFilename
    done
done

mkdir -p ../../plots/$(hostname)/$2

cat $tempFilename | awk 'BEGIN{} {print $4,$10, $13, $14} END{}' | awk '{Prod[$2]++; min[$2]=Prod[$2]==1||min[$2]>$4?$4:min[$2]} END{ for (var in Prod) printf "%s threads: the min is %f\n", var,min[var]}' | sort -n  > ../../plots/$(hostname)/$2/$outputFilename

rm $tempFilename

