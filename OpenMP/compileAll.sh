#!/bin/bash


mkdir -p  buildGnu
mkdir -p  buildIntel
mkdir -p  buildPgi

cd buildGnu
cmake .. ; make clean; make
cd ../

export CC=icc
export CXX=icpc
source setIcc intel64 
source setImpi

cd buildIntel
cmake .. ; make clean; make
cd ../

export CC=pgcc
export CXX=pgc++
source setPgi 18.1
source setPgiMpi 18.10

cd buildPgi
cmake .. ; make clean; make
cd ../

