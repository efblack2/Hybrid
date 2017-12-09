#!/bin/bash

cd Mpi/buildGnu

../runTestMPI.sh laplace_MPI 4000 gnu

cd ../../Mpi+openMP/buildGnu

../runTestMPI+openMP.sh  laplace_MPI+openMP    4000 gnu

cd ../../Mpi+Mpi/buildGnu

../runTestMPI+MPI.sh  laplace_MPI+MPI    4000 gnu

cd ../../

export CC=icc
export CXX=icpc
source setIcc intel64 
source setImpi

cd Mpi/buildIntel

../runTestMPI.sh laplace_MPI 4000 intel

cd ../../Mpi+openMP/buildIntel

../runTestMPI+openMP.sh  laplace_MPI+openMP    4000 intel

cd ../../Mpi+Mpi/buildIntel

../runTestMPI+MPI.sh  laplace_MPI+MPI    4000 intel

cd ../../

export CC=pgcc
export CXX=pgc++
source setPgi 17.10
source setPgiMpi 17.10

cd Mpi/buildPgi

../runTestMPI.sh laplace_MPI 4000 pgi

cd ../../Mpi+openMP/buildPgi

../runTestMPI+openMP.sh  laplace_MPI+openMP    4000 pgi

cd ../../Mpi+Mpi/buildPgi

../runTestMPI+MPI.sh  laplace_MPI+MPI    4000 pgi

cd ../../
