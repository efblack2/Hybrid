#!/bin/bash


mkdir -p  Mpi+Mpi/buildGnu
mkdir -p  Mpi+OpenMP/buildGnu
#mkdir -p  OpenMP/buildGnu

mkdir -p  Mpi+Mpi/buildIntel
mkdir -p  Mpi+OpenMP/buildIntel
#mkdir -p  OpenMP/buildIntel

mkdir -p  Mpi+Mpi/buildPgi
mkdir -p  Mpi+OpenMP/buildPgi
#mkdir -p  OpenMP/buildPgi


cd OpenMP/buildGnu
#cmake .. ; make clean; make
cd ../../Mpi+OpenMP/buildGnu
cmake .. ; make clean; make
cd ../../Mpi+Mpi/buildGnu
cmake .. ; make clean; make
cd ../../

export CC=icc
export CXX=icpc
source setIcc intel64 
source setImpi

cd OpenMP/buildIntel
#cmake .. ; make clean; make
cd ../../Mpi+OpenMP/buildIntel
cmake .. ; make clean; make
cd ../../Mpi+Mpi/buildIntel
cmake .. ; make clean; make
cd ../../

export CC=pgcc
export CXX=pgc++
source setPgi 18.1
source setPgiMpi 18.10

cd OpenMP/buildPgi
#cmake .. ; make clean; make
cd ../../Mpi+OpenMP/buildPgi
cmake .. ; make clean; make
cd ../../Mpi+Mpi/buildPgi
cmake .. ; make clean; make
cd ../../

