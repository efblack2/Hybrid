#!/bin/bash

mkdir   Mpi/buildGnu
mkdir   Mpi+Mpi/buildGnu
mkdir   Mpi+openMP/buildGnu

mkdir   Mpi/buildIntel
mkdir   Mpi+Mpi/buildIntel
mkdir   Mpi+openMP/buildIntel

mkdir   Mpi/buildPgi
mkdir   Mpi+Mpi/buildPgi
mkdir   Mpi+openMP/buildPgi

cd Mpi+openMP/buildGnu
cmake .. ; make
cd ../../Mpi+Mpi/buildGnu
cmake .. ; make
cd ../../Mpi/buildGnu
cmake .. ; make
cd ../../

export CC=icc
export CXX=icpc
source setIcc intel64 
source setImpi

cd Mpi+openMP/buildIntel
cmake .. ; make
cd ../../Mpi+Mpi/buildIntel
cmake .. ; make
cd ../../Mpi/buildIntel
cmake .. ; make
cd ../../

export CC=pgcc
export CXX=pgc++
source setPgi 17.10
source setPgiMpi 17.10

cd Mpi+openMP/buildPgi
cmake .. ; make
cd ../../Mpi+Mpi/buildPgi
cmake .. ; make
cd ../../Mpi/buildPgi
cmake .. ; make
cd ../../

