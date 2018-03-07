#!/bin/bash


mkdir -p  Mpi+Mpi/buildGnu
mkdir -p  Mpi+OpenMP/buildGnu

mkdir -p  Mpi+Mpi/buildIntel
mkdir -p  Mpi+OpenMP/buildIntel

mkdir -p  Mpi+Mpi/buildPgi
mkdir -p  Mpi+OpenMP/buildPgi

cd Mpi+OpenMP/buildGnu
cmake .. ; make
cd ../../Mpi+Mpi/buildGnu
cmake .. ; make
cd ../../

export CC=icc
export CXX=icpc
source setIcc intel64 
source setImpi

cd Mpi+OpenMP/buildIntel
cmake .. ; make
cd ../../Mpi+Mpi/buildIntel
cmake .. ; make
cd ../../

export CC=pgcc
export CXX=pgc++
source setPgi 18.1
source setPgiMpi 18.10

cd Mpi+OpenMP/buildPgi
cmake .. ; make
cd ../../Mpi+Mpi/buildPgi
cmake .. ; make
cd ../../

