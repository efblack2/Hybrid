#!/bin/bash

cd Mpi/buildGnu

../runTestMPI.sh laplace_MPI 4000 gnu

cd ../../Mpi+openMP/buildGnu

../runTestMPI+openMP.sh  laplace_MPI+openMP    4000 gnu

cd ../../Mpi+Mpi/buildGnu

../runTestMPI+Mpi.sh  laplace_MPI+Mpi    4000 gnu

cd ../../

intelMpi

cd Mpi/buildIntel

../runTestMPI.sh laplace_MPI 4000 intel

cd ../../Mpi+openMP/buildIntel

../runTestMPI+openMP.sh  laplace_MPI+openMP    4000 intel

cd ../../Mpi+Mpi/buildIntel

../runTestMPI+Mpi.sh  laplace_MPI+Mpi    4000 intel

cd ../../

pgiMpi

cd Mpi/buildPgi

../runTestMPI.sh laplace_MPI 4000 pgi

cd ../../Mpi+openMP/buildPgi

../runTestMPI+openMP.sh  laplace_MPI+openMP    4000 pgi

cd ../../Mpi+Mpi/buildPgi

../runTestMPI+Mpi.sh  laplace_MPI+Mpi    4000 pgi

cd ../../
