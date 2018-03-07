#Create a variable called linalg_SOURCES containing all .c files:

set(laplace_MPI+openMP_Src 
    src/main.c
    src/laplace.c
    PARENT_SCOPE
    )

