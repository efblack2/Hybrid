#!/bin/bash

cd buildGnu
make clean; make
../runTestOpenMP.sh  laplace_OpenMP  200 gnu


cd ../

source setIcc intel64 
source setImpi

cd buildIntel
make clean; make
../runTestOpenMP.sh  laplace_OpenMP  200 intel

cd ../

source setPgi 18.1
source setPgiMpi 18.10

cd buildPgi
make clean; make
../runTestOpenMP.sh  laplace_OpenMP  200 pgi

cd ../

