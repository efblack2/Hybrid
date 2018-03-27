#!/bin/bash
if [ "$#" -ne 2 ]
then
  echo "Usage: $0 numberOfIterations  compiler"
  exit 1
fi

tempFilename='anyTempFileNameWillWork.txt'
outputFilename='laplace_MPI+MPI.txt'

nloops=3

npt=`grep -c ^processor /proc/cpuinfo`
numaNodes=`lscpu | grep "NUMA node(s):" | awk '{}{print $3}{}'`
tpc=`lscpu | grep "Thread(s) per core:" | awk '{}{print $4}{}'`
np="$(($npt / $tpc))"
npps="$(($np / $numaNodes))"
npm1="$(($np - 1))"


if [ -n "$PGI" ]; then
    echo "Pgi Compiler"
    bindings=" --bind-to core  --report-bindings"
elif [ -n "$INTEL_LICENSE_FILE" ]; then
    echo "Intel Compiler"
    #np=15
    #npps="$(($np / $numaNodes))"
    #npm1="$(($np - 1))"
    bindings="-genv I_MPI_PIN_DOMAIN=core -genv I_MPI_PIN_ORDER=scatter -genv I_MPI_DEBUG=4"
else
    echo "Gnu Compiler"
    bindings=" --bind-to core --report-bindings"
fi

rm -f $tempFilename

for i in 1  `seq 2 2 $np`; do
    for j in  `seq 1 $nloops`; do
        echo number of processors: $i, run number: $j
        mpiexec $bindings  -n $i  laplace_MPI+MPI  $1 | grep Total >>  $tempFilename
        #mpiexec -n $i  taskset -c $sequence  laplace_MPI+MPI  $1 | grep Total >>  $tempFilename
        #aprun -n $i laplace_MPI+MPI  $1 | grep Total >>  $tempFilename
    done
done

mkdir -p ../../plots/$(hostname)/$2

cat $tempFilename | awk 'BEGIN{} {print $4,$6, $11, $17} END{}' | awk '{Prod[$2]++; min[$2]=Prod[$2]==1||min[$2]>$4?$4:min[$2]} END{ for (var in Prod) printf "%s processors: the min is %f\n", var,min[var]}' | sort -n  > ../../plots/$(hostname)/$2/$outputFilename

rm $tempFilename

