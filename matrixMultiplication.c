/** @fn matrixMultiplication.c
    @brief C code for matrix multiplication.
    @author Mustafa Siddiqui
    @date 02/21/20
*/

#include <stdio.h>
#include <stdlib.h>
#define matrixRows 2
#define matrixColumns 4
#define vectorRows 4

int main(void) {

    // initialization
    int matrix[matrixRows][matrixColumns] = {{5, 6, 7, 8}, {9, 10, 11, 12}};
    int vectorX[vectorRows][1] = {{1}, {2}, {3}, {4}};
    int vectorY[vectorRows][1] = {{1}, {2}, {3}, {4}};

    // transpose
    int transposeY[1][vectorRows];
    for (int i = 0; i < vectorRows; i++) {
        transposeY[0][i] = vectorY[i][0];
    }
    printf("Vector Y: %d %d %d\n", vectorY[0][0], vectorY[1][0], vectorY[2][0]);
    printf("Transpose Y: %d %d %d\n", transposeY[0][0], transposeY[0][1], transposeY[0][2]);
    // transpose correct

    // multiply X and transposeY
    int initProduct[vectorRows][vectorRows];
    for (int j = 0; j < vectorRows; j++) {
        for (int i = 0; i < vectorRows; i++) {
            initProduct[j][i] = vectorX[j][0] * transposeY[0][i];
        }
    }
    // multiplication correct

    // multiply matrix with initProduct (3 x 3 matrix multiplication)
    int matrixProduct[matrixRows][vectorRows];
    for (int i = 0; i < matrixRows; i++) {                                  // run to # of rows in matrix
    for (int j = 0; j < matrixColumns; j++) {                               // run to # of columns in matrix
            matrixProduct[i][j] = 0;                                        // initializing matrix before calculations since VLAs cannot be initialized.
            for (int k = 0; k < vectorRows; k++) {                          // run to # of rows in initProduct
                matrixProduct[i][j] += matrix[i][k] * initProduct[k][j];
            }
        }
    }

    // printing the array 
    printf("Matrix Product:\n");
    for (int i = 0; i < matrixRows; i++) {
        for (int j = 0; j < vectorRows; j++) {                              /* # of columns of the second matrix become # of final matrix columns -> 2x4 * 4*3 = 2x3
                                                                                in this code, vectorRows = # of columns in initProduct */  
            printf("%d ", matrixProduct[i][j]);
        }
        printf("\n");
    }
    printf("\n");

    return 0;
}