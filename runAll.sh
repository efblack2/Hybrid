#!/bin/bash

cd Mpi+OpenMP/buildGnu
make clean; make
../runTestMPI+OpenMP.sh 4000 gnu

cd ../../Mpi+Mpi/buildGnu
make clean; make
../runTestMPI+MPI.sh    4000 gnu

cd ../../

source setIcc intel64
source setImpi

cd Mpi+OpenMP/buildIntel
make clean; make
../runTestMPI+OpenMP.sh 4000 intel

cd ../../Mpi+Mpi/buildIntel
make clean; make
../runTestMPI+MPI.sh    4000 intel

cd ../../

source setPgi 18.3
source setPgiMpi 18.3


cd Mpi+OpenMP/buildPgi
make clean; make
../runTestMPI+OpenMP.sh 4000 pgi

cd ../../Mpi+Mpi/buildPgi
make clean; make
../runTestMPI+MPI.sh    4000 pgi

cd ../../

