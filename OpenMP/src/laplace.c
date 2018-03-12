#include <omp.h>
#include <math.h>
// PGI use fmax() in line 16
#include "dataDef.h"

double laplace(double *restrict tNew, double *restrict tOld)
{
    // main calculation: average my four neighbors
    double dt=0.0;  // reset largest temperature change

    #pragma omp for schedule(static) // nowait
    for(int r = COL2; r <=(ROWS*COL2) ; r+=COL2) {
        for(int c = 1; c <= COLUMNS; ++c) {
            tNew[r+c] =  0.25*(tOld[r+c+COL2] + tOld[r+c-COL2] + tOld[r+c+1] + tOld[r+c-1]);
            #ifndef PGI
            dt = fabs( tNew[r+c] - tOld[r+c] ) > dt ?  fabs( tNew[r+c] - tOld[r+c] ) : dt;
            #else
            dt = fmax(  fabs( tNew[r+c] - tOld[r+c] ), dt);
            #endif
        } // end for //
    } // end for //
    return dt;
} // end of laplace() //
