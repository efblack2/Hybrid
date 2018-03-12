#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include <sys/time.h>
#include <omp.h>

#include "dataDef.h"

//   helper routines
void initialize(double *Temperature, double *Temperature_last);
void track_progress(int iter, double *Temperature);

double laplace(double *restrict tNew, double *restrict tOld);

int main(int argc, char *argv[]) 
{
    int max_iterations;                                  // number of iterations
    int iteration=0;                                     // current iteration
    double dt;                                           // largest change in t
    struct timeval tp;                                   // timer
    double elapsed_time;
    const int size = ROW2 * COL2;
    int nthreads;
    
    double *restrict Temperature;                       // temperature grid
    double *restrict Temperature_last;                  // temperature grid from last iteration
    double *restrict temp;                              // temporary pointer to switch pointers

    Temperature      = malloc(size*sizeof(double));
    Temperature_last = malloc(size*sizeof(double));

    #pragma omp parallel
    { 
        nthreads = omp_get_num_threads();
    } // end of parallel region
    

    if (argc > 1 ) {
        max_iterations=atoi(argv[1]);
    } else {
        printf("Maximum iterations [100-4000]?\n");
        if ( !scanf("%d", &max_iterations)  || max_iterations < 0 ) {
            printf("wrong input value\nBye...\n");
            exit(0);
        } // end if //       
    } // endif //
    
    
    
    printf("Ruuning %d iterations \n",max_iterations);

    gettimeofday(&tp,NULL);  // Unix timer
    elapsed_time = -(tp.tv_sec*1.0e6 + tp.tv_usec);  

    initialize(Temperature,Temperature_last);             // initialize Temp_last including boundary conditions

    // do until error is minimal or until max steps
    do {
        iteration++;
        dt = 0.0; // reset largest temperature change
        #pragma omp parallel reduction (max:dt)
        dt = laplace(Temperature,Temperature_last);
        // periodically print test values
        if((iteration % 100) == 0) {
 	        track_progress(iteration,Temperature );
 	        printf("Max error at iteration %d is %f\n", iteration, dt);
        } // end if //
        temp = Temperature_last;
        Temperature_last=Temperature;
        Temperature=temp;        
    } while (dt > MAX_TEMP_ERROR && iteration < max_iterations) ; // end do-while //

    gettimeofday(&tp,NULL);
    elapsed_time += (tp.tv_sec*1.0e6 + tp.tv_usec);

    printf("\nMax error at iteration %d was %f\n", iteration, dt);
    printf ("Total time for %d nodes, %d MPI processors and %d openMP threads was %f seconds.\n", 1, 0, nthreads,elapsed_time*1.0e-6);
    
    free(Temperature);
    free(Temperature_last);
    return 0;

} // end main() // 


// initialize plate and boundary conditions
// Temp_last is used to to start first iteration
void initialize(double *Temperature, double *Temperature_last)
{
    #pragma omp parallel for
    for(int r = 0; r < ROW2*COL2; r+=COL2){
        for (int c = 0; c <= COLUMNS+1; ++c){
            Temperature[r+c] = Temperature_last[r+c] = 0.0;
        } // end for //
    } // end for //

    // these boundary conditions never change throughout run

    // set left side to 0 and right to a linear increase
    for(int r = 0; r < ROW2*COL2; r+=COL2) {
        Temperature[r] = Temperature_last[r] = 0.0;
        Temperature[r+COLUMNS+1] = Temperature_last[r+COLUMNS+1] = (100.0/ROWS)*r/ROW2;
    } // end for //
    
    // set top to 0 and bottom to linear increase
    for(int c = 0; c < COL2; ++c) {
        Temperature[c] = Temperature_last[c] = 0.0;
        Temperature[(ROWS+1)*COL2+c] = Temperature_last[(ROWS+1)*COL2+c] = (100.0/COLUMNS)*c;
    } // end for //
} // end initialize() //


// print diagonal in bottom right corner where most action is
void track_progress(int iteration, double *T) 
{
    printf("---------- Iteration number: %d ------------\n", iteration);
    for(int r = ROWS-5; r <= ROWS; ++r) {
        printf("[%d,%d]: %5.2f  ", r, r, T[r*COL2+r]);
    } // end for //
    printf("\n");
} // end  track_progress()//
