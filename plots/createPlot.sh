#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0  computer"
  exit 1
fi

cd $1/gnu
paste laplace_MPI+MPI.txt  laplace_MPI+OpenMP.txt > laplace.txt

cd ../intel
paste laplace_MPI+MPI.txt  laplace_MPI+OpenMP.txt > laplace.txt

cd ../pgi
paste laplace_MPI+MPI.txt  laplace_MPI+OpenMP.txt > laplace.txt

cd ../..


gnuplot -c plot.gnp $1 
gnuplot -c plotRatio.gnp $1 

gnuplot -c plotGnu.gnp $1  
gnuplot -c plotGnuRatio.gnp $1  

rm `find . -name  laplace.txt`
