The program in this directory corresponds to
the hybrid MPI+MPI_sm implementation.

# Build Instructions

To compile the program,

1. Create a build directory
```bash
mkdir build
```
2. Configure the build

```bash
cd build
cmake [OPTIONS] ..
```
3. Create the program

```bash
make
```

To run the program, just invoke the program and pass as parameter 
a number of iterations. If no parameter is given 1000 iterations are
performed.

For example:
    
        $ mpiexec -n 4 laplace_MPI+MPI 1000

Note:
In Blue Waters aprun must be used instead of mpiexec as in:

        $ aprun -n 4 -N 2 laplace_MPI+MPI 1000

In the previous example the program will run using four processors
but limiting the number of processors to 2 per node.

