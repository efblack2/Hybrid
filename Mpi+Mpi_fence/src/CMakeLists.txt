#Create a variable called linalg_SOURCES containing all .c files:

set(laplace_MPI+MPI_Src 
    src/main.c
    src/laplace.c
    PARENT_SCOPE
    )

