#!/bin/bash

cd Mpi+OpenMP/buildGnu
make clean; make
../runNodesTest.sh 1000 gnu

cd ../../Mpi+Mpi/buildGnu
make clean; make
../runNodesTest.sh 1000 gnu

cd ../../Mpi/buildGnu
make clean; make
../runNodesTest.sh 1000 gnu

#cd ../../Mpi+Mpi_fence/buildGnu
#make clean; make
#../runTest.sh 1000 gnu

cd ../../

source setIcc intel64
source setImpi

cd Mpi+OpenMP/buildIntel
make clean; make
../runNodesTest.sh 1000 intel

cd ../../Mpi+Mpi/buildIntel
make clean; make
../runNodesTest.sh 1000 intel

cd ../../Mpi/buildIntel
make clean; make
../runNodesTest.sh 1000 intel

cd ../../

source setPgi 18.x
source setPgiMpi 18.x


cd Mpi+OpenMP/buildPgi
make clean; make
../runNodesTest.sh 1000 pgi

cd ../../Mpi+Mpi/buildPgi
make clean; make
../runNodesTest.sh 1000 pgi

cd ../../Mpi/buildPgi
make clean; make
../runNodesTest.sh 1000 pgi

#cd ../../Mpi+Mpi_fence/buildPgi
#make clean; make
#../runTest.sh 1000 pgi

cd ../../

