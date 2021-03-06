#!/bin/bash
if [ "$#" -lt 1 ]
then
  echo "Usage: $0  computer"
  exit 1
fi

cd $1/gnu
paste laplace_MPI+OpenMP.txt laplace_MPI.txt  > laplace.txt
paste laplace_MPI+MPI.txt    laplace_MPI.txt  > laplace2.txt
#paste laplace_MPI+MPI.txt  laplace_MPI+MPI_fence.txt > laplace_fence.txt

cd ../intel
paste laplace_MPI+OpenMP.txt laplace_MPI.txt  > laplace.txt
paste laplace_MPI+MPI.txt    laplace_MPI.txt  > laplace2.txt
#paste laplace_MPI+MPI.txt  laplace_MPI+MPI_fence.txt > laplace_fence.txt

cd ../pgi
paste laplace_MPI+OpenMP.txt laplace_MPI.txt  > laplace.txt
paste laplace_MPI+MPI.txt    laplace_MPI.txt  > laplace2.txt
#paste laplace_MPI+MPI.txt  laplace_MPI+MPI_fence.txt > laplace_fence.txt

cd ../..


gnuplot -c plot.gnp $1 
gnuplot -c plotRatio.gnp $1 

mv $1.pdf temp.pdf
pdfunite temp.pdf $1Ratio.pdf $1.pdf

rm temp.pdf $1Ratio.pdf

gnuplot -c plotGnu.gnp $1  
gnuplot -c plotGnuRatio.gnp $1  


mv $1_Gnu.pdf temp.pdf
pdfunite temp.pdf $1Ratio_Gnu.pdf $1_Gnu.pdf

rm temp.pdf $1Ratio_Gnu.pdf




rm `find . -name  laplace.txt`
rm `find . -name  laplace2.txt`
#rm `find . -name  laplace_fence.txt`

