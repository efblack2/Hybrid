#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0  compiler"
  exit 1
fi

cd cluster/$1
paste laplace_MPI.txt laplace_MPI+OpenMP.txt laplace_MPI+MPI.txt  > laplace.txt
cd ../..

gnuplot -c plotCluster.gnp $1  



rm `find . -name  laplace.txt`

