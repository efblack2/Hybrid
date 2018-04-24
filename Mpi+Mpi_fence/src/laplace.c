#include <math.h>
#include "dataDef.h"

double laplace(double *restrict tNew, double *restrict tOld, int nRows)
{
    // main calculation: average my four neighbors
    //printf("nRows: %d\n", nRows);
    double dt=0.0;   // reset largest temperature change

    
    for(int r = COL2; r <=(nRows*COL2) ; r+=COL2) {
        for(int c = 1; c <= COLUMNS; ++c) {
            tNew[r+c] =  0.25*(tOld[r+c+COL2] + tOld[r+c-COL2] + tOld[r+c+1] + tOld[r+c-1]);
            # ifndef PGI
            dt = fabs( tNew[r+c] - tOld[r+c] ) > dt ?  fabs( tNew[r+c] - tOld[r+c] ) : dt;
            # else
            dt = fmax(  fabs( tNew[r+c] - tOld[r+c] ), dt);
            #endif
        } // end for //
    } // end for //
    
    return dt;
} // end of laplace() //
