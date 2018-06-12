#!/bin/bash


mkdir -p  Mpi/buildGnu
mkdir -p  Mpi+Mpi/buildGnu
#mkdir -p  Mpi+Mpi_fence/buildGnu
mkdir -p  Mpi+OpenMP/buildGnu

mkdir -p  Mpi/buildIntel
mkdir -p  Mpi+Mpi/buildIntel
#mkdir -p  Mpi+Mpi_fence/buildIntel
mkdir -p  Mpi+OpenMP/buildIntel

mkdir -p  Mpi/buildPgi
mkdir -p  Mpi+Mpi/buildPgi
#mkdir -p  Mpi+Mpi_fence/buildPgi
mkdir -p  Mpi+OpenMP/buildPgi


cd Mpi+OpenMP/buildGnu
cmake .. ; make clean; make
cd ../../Mpi+Mpi/buildGnu
cmake .. ; make clean; make
cd ../../Mpi/buildGnu
cmake .. ; make clean; make
#cd ../../Mpi+Mpi_fence/buildGnu
#cmake .. ; make clean; make
cd ../../


export CC=icc
export CXX=icpc
source setIcc intel64
source setImpi

cd Mpi+OpenMP/buildIntel
cmake .. ; make clean; make
cd ../../Mpi+Mpi/buildIntel
cmake .. ; make clean; make
cd ../../Mpi/buildIntel
cmake .. ; make clean; make
#cd ../../Mpi+Mpi_fence/buildIntel
#cmake .. ; make clean; make
cd ../../

export CC=pgcc
export CXX=pgc++
source setPgi 18.x
source setPgiMpi 18.x

cd Mpi+OpenMP/buildPgi
cmake .. ; make clean; make
cd ../../Mpi+Mpi/buildPgi
cmake .. ; make clean; make
cd ../../Mpi/buildPgi
cmake .. ; make clean; make
#cd ../../Mpi+Mpi_fence/buildPgi
#cmake .. ; make clean; make
cd ../../

