#!/bin/bash
if [ "$#" -ne 2 ]
then
  echo "Usage: $0 numberOfIterations  compiler"
  exit 1
fi

tempFilename='anyTempFileNameWillWork.txt'
outputFilename='laplace_MPI+OpenMP.txt'

nloops=5

# Determining MPI implementation and binding options #
MPI=`mpiexec --version | head -1 | awk '{print $1}' `

if [ "$MPI" == "HYDRA" ]; then
    echo "MPICH"
    bindings="--bind-to none"
    export HYDRA_TOPO_DEBUG=1
elif [ "$MPI" == "Intel(R)" ]; then
    echo "Intel MPI"
    bindings="-genv I_MPI_PIN_DOMAIN=node -genv I_MPI_PIN_ORDER=spread -genv I_MPI_DEBUG=4 -genv I_MPI_FABRICS=shm:ofi"
elif [ "$MPI" == "mpiexec" ]; then
    echo "open-mpi"
    bindings="--bind-to none --report-bindings"
fi
# end of Determining MPI implementation and binding options #


npt=`grep -c ^processor /proc/cpuinfo`
numaNodes=`lscpu | grep "NUMA node(s):" | awk '{}{print $3}{}'`
tpc=`lscpu | grep "Thread(s) per core:" | awk '{}{print $4}{}'`
#np="$(($npt / $tpc))"
np=16

npps="$(($np / $numaNodes))"
npm1="$(($np - 1))"


seqArray=()
##########################################
for i in  `seq 0 $((npps-1))`; do
    for j in `seq 0 $((numaNodes-1))`; do
        seqArray[i*$numaNodes+j]=$((i+j*npps))
    done
done
##########################################
#for i in `seq 0 $((npm1))`; do
#    seqArray[i]=$i
#done
##########################################
#for i in `seq 0 2 $((npm1))`; do
#    sequence+=$i','
#done
#for i in `seq 1 2 $((npm1))`; do
#    sequence+=$i','
#done
##########################################

#echo ${seqArray[*]}
sequence=''
for p in `seq 0 $((  npm1  ))`; do
    sequence+=${seqArray[p]}','
done
sequence=${sequence%?}


rm -f $tempFilename

#nnodes=3
nnodes=4

for i in  1 `seq 2  2 $np`; do
    nRanks="$(($nnodes*$i))"
    if [ "$MPI" == "Intel(R)" ]; then
        ompParameters="-genv OMP_NUM_THREADS=$i -genv OMP_PROC_BIND=spread -genv OMP_PLACES=cores -genv OMP_DISPLAY_ENV=true "
    elif [ "$MPI" == "mpiexec" ]; then
        ompParameters="-x    OMP_NUM_THREADS=$i -x    OMP_PROC_BIND=spread -x    OMP_PLACES=sockets -x  OMP_DISPLAY_ENV=true "
    fi
    #echo $ompParameters
    for j in  `seq 1 $nloops`; do
        echo number of threads: $i, run number: $j
        if [ "$MPI" == "Intel(R)" ]; then
            mpiexec $bindings $ompParameters -hosts stout,koelsch,dunkel,porter  -n $nnodes -ppn 1 laplace_MPI+OpenMP $1 | grep Total >>  $tempFilename
        elif [ "$MPI" == "mpiexec" ]; then
            mpiexec $bindings $ompParameters -host stout:1,koelsch:1,dunkel:1,porter:1  -n $nnodes laplace_MPI+OpenMP $1 | grep Total >>  $tempFilename
        fi
        #mpiexec $bindings $ompParameters -host koelsch:1,dunkel:1,porter:1  -n $nnodes laplace_MPI+OpenMP $1 | grep Total >>  $tempFilename
    done
done


mkdir -p ../../plots/cluster/$2

cat $tempFilename | awk 'BEGIN{} {print $4,$10, $13, $14} END{}' | awk '{Prod[$2]++; min[$2]=Prod[$2]==1||min[$2]>$4?$4:min[$2]} END{ for (var in Prod) printf "%s threads: the min is %f\n", var,min[var]}' | sort -n  > ../../plots/cluster/$2/$outputFilename

rm $tempFilename

