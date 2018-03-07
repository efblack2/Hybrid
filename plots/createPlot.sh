#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0  computer"
  exit 1
fi



gnuplot -c plot.gnp $1 
gnuplot -c plotRatio.gnp $1 

gnuplot -c plotGnu.gnp $1  
gnuplot -c plotGnuRatio.gnp $1  

