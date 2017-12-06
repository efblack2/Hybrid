The programs in this directory corresponds to
an example consisting of a Jacobi iteration, solving 
the 2D-Laplace equation within some allowable tolerance.

The intention is to compare the performance of "pure" MPI
implementation to "Hybrids" versions using shared memory.
Two hybrid version are developed: one combines MPI and openMP 
(MPI+openMP) while the other utilizes the new share memory capabilities 
added to MPI. (MPI+MPI_sm)

See the Readme.md files inside each directory for more details.
