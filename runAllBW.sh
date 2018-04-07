#!/bin/bash

cd Mpi+OpenMP/buildGnu
make clean; make
../runTestBW.sh 1000 gnu

cd ../../Mpi+Mpi/buildGnu
make clean; make
../runTestBW.sh 1000 gnu

cd ../../

source setIcc


cd Mpi+OpenMP/buildIntel
make clean; make
../runTestBW.sh 1000 intel

cd ../../Mpi+Mpi/buildIntel
make clean; make
../runTestBW.sh 1000 intel

cd ../../

source setPgi


cd Mpi+OpenMP/buildPgi
make clean; make
../runTestBW.sh 1000 pgi

cd ../../Mpi+Mpi/buildPgi
make clean; make
../runTestBW.sh 1000 pgi

cd ../../

