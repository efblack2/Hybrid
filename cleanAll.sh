#!/bin/bash

cd OpenMP/
rm -rf buildGnu  buildIntel  buildPgi
cd ../Mpi+OpenMP/
rm -rf buildGnu  buildIntel  buildPgi
cd ../Mpi+Mpi/
rm -rf buildGnu  buildIntel  buildPgi
cd ../Mpi+Mpi_fence/
rm -rf buildGnu  buildIntel  buildPgi
cd ..

