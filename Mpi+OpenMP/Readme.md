The program in this directory corresponds to
the hybrid MPI+openMP implementation.

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
    
        $ laplace_MPI+openMP 1000

Note: You can force the program to run using a prefixed number of
      threads by setting the OMP_NUM_THREADS variable.
      
For example:
        $ export OMP_NUM_THREADS=4
        $ laplace_MPI+openMP 1000

will force the program to run using 4 threads.
