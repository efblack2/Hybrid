#!/bin/bash
if [ "$#" -ne 2 ]
then
  echo "Usage: $0 numberOfIterations  compiler"
  exit 1
fi

tempFilename='anyTempFileNameWillWork.txt'
outputFilename='laplace_MPI.txt'

nloops=4

# Determining MPI implementation and binding options #
MPI=`mpiexec --version | head -1 | awk '{print $1}' `

if [ "$MPI" == "HYDRA" ]; then
    echo "MPICH"
    bindings="--bind-to socket"
    export HYDRA_TOPO_DEBUG=1
elif [ "$MPI" == "Intel(R)" ]; then
    echo "Intel MPI"
    bindings="-genv I_MPI_PIN_DOMAIN=core -genv I_MPI_PIN_ORDER=spread -genv I_MPI_DEBUG=4"
elif [ "$MPI" == "mpiexec" ]; then
    echo "open-mpi"
    bindings="--bind-to core --report-bindings"
fi
# end of Determining MPI implementation and binding options #

npt=`grep -c ^processor /proc/cpuinfo`
numaNodes=`lscpu | grep "NUMA node(s):" | awk '{}{print $3}{}'`
tpc=`lscpu | grep "Thread(s) per core:" | awk '{}{print $4}{}'`
np="$(($npt / $tpc))"
npps="$(($np / $numaNodes))"
npm1="$(($np - 1))"


rm -f $tempFilename

nnodes=3
for i in 1  `seq 2 2 $np`; do
    nRanks="$(($nnodes*$i))"
    #echo $nRanks
    for j in  `seq 1 $nloops`; do
        echo number of processors: $nRanks, run number: $j
        mpiexec $bindings -host stout:$i,porter:$i,koelsch:$i -n $nRanks  laplace_MPI  $1 | grep Total >>  $tempFilename
    done
done


mkdir -p ../../plots/cluster/$2

cat $tempFilename | awk 'BEGIN{} {print $4,$7, $11} END{}' | awk '{Prod[$2]++; min[$2]=Prod[$2]==1||min[$2]>$3?$3:min[$2]} END{ for (var in Prod) printf "%s processors: the min is %f\n", var,min[var]}' | sort -n  > ../../plots/cluster/$2/$outputFilename

rm $tempFilename

