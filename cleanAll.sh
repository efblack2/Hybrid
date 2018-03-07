#!/bin/bash

cd Mpi+OpenMP/buildGnu
make clean
cd ../../Mpi+Mpi/buildGnu
make clean
cd ../../

cd Mpi+OpenMP/buildIntel
make clean
cd ../../Mpi+Mpi/buildIntel
make clean
cd ../../

cd Mpi+OpenMP/buildPgi
make clean
cd ../../Mpi+Mpi/buildPgi
make clean
cd ../../

