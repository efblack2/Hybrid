#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <mpi.h>
#include "myMPI.h"


#include "dataDef.h"

//   helper routines
void initialize(double *Temperature, double *Temperature_last,int sRow,int eRow, int rank, int lastRank);
void track_progress(int iter, double *Temperature,  int sRow, int eRow);

double laplace(double *restrict tNew, double *restrict tOld, int nRows);

int main(int argc, char *argv[]) 
{
    int provided;
    MPI_Init_thread(&argc, &argv, MPI_THREAD_SINGLE, &provided);
    MPI_Status status[2];
    MPI_Request request[2];

    MPI_Comm sm_comm;
    MPI_Comm_split_type(MPI_COMM_WORLD,MPI_COMM_TYPE_SHARED, 0,MPI_INFO_NULL, &sm_comm);

    int myWorldRank, worldSize;
    
    MPI_Comm_rank(MPI_COMM_WORLD,&myWorldRank);
    MPI_Comm_size(MPI_COMM_WORLD,&worldSize);

    int mySharedRank,sharedSize;
    MPI_Comm_rank(sm_comm,&mySharedRank);
    MPI_Comm_size(sm_comm,&sharedSize);
    int nNodes=CEILING(worldSize,sharedSize);


    const int root=0; 
    //const int root=commSize-1; 

    MPI_Group sharedGroup,worldGroup;
    
    MPI_Comm_group(MPI_COMM_WORLD, &worldGroup);
    MPI_Comm_group(sm_comm, &sharedGroup);
    
    int *partners, *map;
    partners = (int *)malloc( worldSize * sizeof(int) );
    map      = (int *)malloc( worldSize * sizeof(int) );
    
    MPI_Allgather(&myWorldRank, 1, MPI_INT,partners,1,MPI_INT,MPI_COMM_WORLD);
    MPI_Group_translate_ranks(worldGroup, worldSize, partners, sharedGroup, map);

    const int sRow = (BLOCK_LOW (myWorldRank,worldSize,ROWS)+1);
    const int eRow = (BLOCK_HIGH(myWorldRank,worldSize,ROWS)+1);
    const int nRows=eRow-sRow + 3;
    

    int max_iterations;                                 // number of iterations
    int iteration=0;                                    // current iteration
    double dt=0.0;                                      // largest change in t
    double elapsed_time;


    if (argc > 1 ) {
        max_iterations=atoi(argv[1]);
    } // end if //
    
    if ( (argc <= 1 || max_iterations < 0 ) ) {  // using rank 0 because of scanf()
        if (myWorldRank == 0) {                              // using rank 0 because of scanf()
            printf("Maximum iterations [100-4000]?: ");fflush(stdout);
            while ( !scanf("%d", &max_iterations)  || max_iterations < 0 ) {
                printf("wrong input value. Try again... ");fflush(stdout);
            } // end while //
        } // end if //
        MPI_Bcast(&max_iterations, 1, MPI_INT, 0,MPI_COMM_WORLD);    
    } // endif //

    if (myWorldRank == root) printf("Running %d iterations \n",max_iterations);fflush(stdout);

/*
    printf("worldRank: %d, sRow: %d, eRow: %d, nRows: %d\n",myWorldRank,sRow,eRow,nRows );
    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Finalize();
    exit(0);
*/
    
    
    double *Temperature;                       // temperature grid
    double *Temperature_last;                  // temperature grid from last iteration
    double *temp;                              // temporary pointer to switch pointers
    
    const int size = nRows * COL2;

    /*
    Temperature      = malloc(size*sizeof(double));
    Temperature_last = malloc(size*sizeof(double));
    */

    MPI_Win sm_winT0,sm_winT1;
    MPI_Aint sz;
    int dispUnit;
    
    MPI_Win_allocate_shared((MPI_Aint) size*sizeof(double),sizeof(double),MPI_INFO_NULL,sm_comm,&Temperature_last,&sm_winT0);
    MPI_Win_allocate_shared((MPI_Aint) size*sizeof(double),sizeof(double),MPI_INFO_NULL,sm_comm,&Temperature,     &sm_winT1);
    
    MPI_Win_shared_query(sm_winT0, mySharedRank, &sz,&dispUnit,&Temperature_last);
    MPI_Win_shared_query(sm_winT1, mySharedRank, &sz,&dispUnit,&Temperature);


    MPI_Barrier(MPI_COMM_WORLD);
    elapsed_time = -MPI_Wtime();

    //MPI_Win_lock_all(0,sm_winT0);
    //MPI_Win_lock_all(0,sm_winT1);

    
    if ( myWorldRank < worldSize-1 && map[myWorldRank+1] != MPI_UNDEFINED ) {
        MPI_Win_lock(MPI_LOCK_SHARED,mySharedRank+1,0,sm_winT0);
        MPI_Win_lock(MPI_LOCK_SHARED,mySharedRank+1,0,sm_winT1);
    } // end if //  

    if ( myWorldRank > 0           && map[myWorldRank-1] != MPI_UNDEFINED ) {
        MPI_Win_lock(MPI_LOCK_SHARED,mySharedRank-1,0,sm_winT0);
        MPI_Win_lock(MPI_LOCK_SHARED,mySharedRank-1,0,sm_winT1);
    } // end if //  
      
    initialize(Temperature,Temperature_last,sRow, eRow, myWorldRank,worldSize-1); // initialize Temp_last including boundary conditions
    
    if (sharedSize>1) {
        MPI_Win_sync(sm_winT0);
        MPI_Win_sync(sm_winT1);
        MPI_Barrier(sm_comm);
    } // end if //  


    if ( myWorldRank < worldSize-1 && map[myWorldRank+1] != MPI_UNDEFINED ) {
        MPI_Win_unlock(mySharedRank+1,sm_winT0);
    } // end if //  

    if ( myWorldRank > 0           && map[myWorldRank-1] != MPI_UNDEFINED ) {
        MPI_Win_unlock(mySharedRank-1,sm_winT0);
    } // end if //  
    //MPI_Win_unlock_all(sm_winT0);

    
    // do until error is minimal or until max steps
    do {
        ++iteration;
        dt = laplace(Temperature,Temperature_last,nRows-2);
        
        if (myWorldRank < worldSize-1) { 
            if (map[myWorldRank+1] != MPI_UNDEFINED) {
                memcpy(&Temperature[(nRows)*COL2],&Temperature[(nRows-2)*COL2], COL2*sizeof(double));
            } else {
                MPI_Irecv(&Temperature[(nRows-1)*COL2],COL2,MPI_DOUBLE,myWorldRank+1,200,MPI_COMM_WORLD,&request[0]);
                MPI_Isend(&Temperature[(nRows-2)*COL2],COL2,MPI_DOUBLE,myWorldRank+1,100,MPI_COMM_WORLD,&request[1]);
            } // end if //  
        } // end if //  

        if (myWorldRank > 0)  {
            if (map[myWorldRank-1] != MPI_UNDEFINED) {
                memcpy(&Temperature[-COL2],&Temperature[COL2], COL2*sizeof(double));
            } else {
                MPI_Irecv(&Temperature[0]   ,COL2,MPI_DOUBLE,myWorldRank-1,100,MPI_COMM_WORLD,&request[0]);
                MPI_Isend(&Temperature[COL2],COL2,MPI_DOUBLE,myWorldRank-1,200,MPI_COMM_WORLD,&request[1]);
            } // end if //
        } // end if //
        
        MPI_Allreduce(MPI_IN_PLACE,&dt, 1,MPI_DOUBLE,MPI_MAX,MPI_COMM_WORLD);

        if (myWorldRank < worldSize-1 && map[myWorldRank+1] == MPI_UNDEFINED ) { 
            MPI_Waitall(2,request, status);
        } // end if //  

        if (myWorldRank > 0 && map[myWorldRank-1] == MPI_UNDEFINED)  {
            MPI_Waitall(2,request, status);
        } // end if //
        
        if (sharedSize>1) {
            MPI_Win_sync(sm_winT1);
            MPI_Barrier(sm_comm);
            //MPI_Win_sync(sm_winT0);
            //MPI_Barrier(MPI_COMM_WORLD);
        } // end if //

        temp = Temperature_last;
        Temperature_last=Temperature;
        Temperature=temp;        
        
        // periodically print test values
        if((iteration % 100) == 0  && myWorldRank == worldSize-1 ) {
 	        track_progress(iteration,Temperature_last, sRow, eRow );
 	        printf("Max error at iteration %d is %f\n", iteration, dt);
        } // end if //
        
    } while (dt > MAX_TEMP_ERROR && iteration < max_iterations) ; // end do-while //
    
    if ( myWorldRank < worldSize-1 && map[myWorldRank+1] != MPI_UNDEFINED ) {
        MPI_Win_unlock(mySharedRank+1,sm_winT1);
    } // end if //  

    if ( myWorldRank > 0           && map[myWorldRank-1] != MPI_UNDEFINED ) {
        MPI_Win_unlock(mySharedRank-1,sm_winT1);
    } // end if //  
    
    
    //MPI_Win_unlock_all(sm_winT1);
    

    MPI_Barrier(MPI_COMM_WORLD);
    elapsed_time += MPI_Wtime();
    
    if (myWorldRank == root) {
        printf("\nMax error at iteration %d was %f\n", iteration, dt);
        printf ("Total time for %d nodes, %d total MPI processors and %d MPI processors per node was %f seconds.\n",nNodes, worldSize, sharedSize,elapsed_time);
    } // end if //
    
    /*
    free(Temperature);
    free(Temperature_last);
    */
    MPI_Win_free(&sm_winT0);
    MPI_Win_free(&sm_winT1);

    free(partners);
    free(map);
    /*
    if (mySharedRank==0) {
        printf("mySharedRank: %2d,sharedSize:%2d, myWorldRank: %2d, worldSize: %2d\n",mySharedRank,sharedSize,myWorldRank,worldSize);
    } // end if //
    */
    MPI_Finalize();
    return 0;

} // end main() // 


// initialize plate and boundary conditions
// Temp_last is used to to start first iteration
void initialize(double *Temperature, double *Temperature_last, int sRow, int eRow, int rank, int lastRank)
{
    int nRows = eRow-sRow + 3;
    
    for(int r = 0; r < nRows*COL2; r+=COL2){
        for (int c = 0; c <= COLUMNS+1; ++c){
            Temperature[r+c] = Temperature_last[r+c] = 0.0;
        } // end for //
    } // end for //
    // these boundary conditions never change throughout run

    // set left side to 0 and right to a linear increase
    for(int r = 0; r < nRows*COL2; r+=COL2){
        Temperature[     r     ] = Temperature_last[     r     ] = 0.0;
        Temperature[r+COLUMNS+1] = Temperature_last[r+COLUMNS+1] = (100.0/ROWS) * (r/COL2 + sRow-1);
    } // end for //
    
    if (rank == 0) {                                // set top to 0 
        for(int c = 0; c < COL2; ++c) {
            Temperature[c] = Temperature_last[c] = 0.0;
        } // end for //
    } // end if // 
    
    if (rank == lastRank) {                  // set bottom to linear increase
        for(int c = 0; c < COL2; ++c) {
            Temperature[(nRows-1)*COL2+c] = Temperature_last[(nRows-1)*COL2+c] = (100.0/COLUMNS)*c;
        } // end for //
    } // end if //
} // end initialize() //


// print diagonal in bottom right corner where most action is
void track_progress(int iteration, double *T,  int sRow, int eRow) 
{   
    const int n = 5;
    const int nRows = eRow-sRow + 3;
    int r = COLUMNS-n;
    int c = (nRows-n-2)*COL2+r;

    printf("---------- Iteration number: %d ------------\n", iteration);
    for(int i = 0; i <= n; ++i, ++r,c+=COL2+1) {
        printf("[%d,%d]: %8.5e  ", r, r, T[c]);
    } // end for //
    printf("\n");   

} // end  track_progress()//


/*    
    if (mySharedRank==0) {
        printf("total processors: %d, local processors %d worldRank: %d\n",worldSize, sharedSize, myWorldRank);fflush(stdout);
    }
    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Finalize();
    exit(0);
*/    
    
/*    
    if (worldSize==sharedSize) {
        printf("running in one node\n");fflush(stdout);
    }  // end if //
    printf("worldSize: %d,sharedSize %d\n",worldSize,sharedSize );fflush(stdout);
    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Finalize();
    exit(0);
*/    

