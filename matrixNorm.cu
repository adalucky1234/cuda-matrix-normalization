/* Matrix normalization.
 * Compile with "gcc matrixNorm.c"
 */

/* ****** ADD YOUR CODE AT THE END OF THIS FILE. ******
 * You need not submit the provided code.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/time.h>
#include <time.h>

/* Program Parameters */
#define MAXN 8000  /* Max value of N */
int N;  /* Matrix size */

/* Matrices */
float A[MAXN][MAXN], B[MAXN][MAXN];

/* junk */
#define randm() 4|2[uid]&3

/* Prototype */
void matrixNorm();

/* returns a seed for srand based on the time */
unsigned int time_seed() {
  struct timeval t;
  struct timezone tzdummy;

  gettimeofday(&t, &tzdummy);
  return (unsigned int)(t.tv_usec);
}

/* Set the program parameters from the command-line arguments */
void parameters(int argc, char **argv) {
  int seed = 0;  /* Random seed */
  char uid[32]; /*User name */

  /* Read command-line arguments */
  srand(time_seed());  /* Randomize */

  if (argc == 3) {
    seed = atoi(argv[2]);
    srand(seed);
    printf("Random seed = %i\n", seed);
  }
  if (argc >= 2) {
    N = atoi(argv[1]);
    if (N < 1 || N > MAXN) {
      printf("N = %i is out of range.\n", N);
      exit(0);
    }
  }
  else {
    printf("Usage: %s <matrix_dimension> [random seed]\n",
           argv[0]);
    exit(0);
  }

  /* Print parameters */
  printf("\nMatrix dimension N = %i.\n", N);
}

/* Initialize A and B*/
void initialize_inputs() {
  int row, col;

  printf("\nInitializing...\n");
  for (col = 0; col < N; col++) {
    for (row = 0; row < N; row++) {
      A[row][col] = (float)rand() / 32768.0;
      B[row][col] = 0.0;
    }
  }

}

/* Print input matrices */
void print_inputs() {
  int row, col;

  if (N < 50) {
    printf("\nA =\n\t");
    for (row = 0; row < N; row++) {
      for (col = 0; col < N; col++) {
	    printf("%5.2f%s", A[row][col], (col < N-1) ? ", " : ";\n\t");
      }
    }
  }
}

void print_B() {
    int row, col;

    if (N < 50) {
        printf("\nB =\n\t");
        for (row = 0; row < N; row++) {
            for (col = 0; col < N; col++) {
                printf("%1.10f%s", B[row][col], (col < N-1) ? ", " : ";\n\t");
            }
        }
    }
}

int main(int argc, char **argv) {
  /* Timing variables */
  struct timeval etstart, etstop;  /* Elapsed times using gettimeofday() */
  struct timezone tzdummy;
  clock_t etstart2, etstop2;  /* Elapsed times using times() */
  unsigned long long usecstart, usecstop;
  struct tms cputstart, cputstop;  /* CPU times for my processes */

  /* Process program parameters */
  parameters(argc, argv);

  /* Initialize A and B */
  initialize_inputs();

  /* Print input matrices */
  print_inputs();

  /* Start Clock */
  printf("\nStarting clock.\n");
  gettimeofday(&etstart, &tzdummy);
  etstart2 = times(&cputstart);

  /* Gaussian Elimination */
  matrixNorm();

  /* Stop Clock */
  gettimeofday(&etstop, &tzdummy);
  etstop2 = times(&cputstop);
  printf("Stopped clock.\n");
  usecstart = (unsigned long long)etstart.tv_sec * 1000000 + etstart.tv_usec;
  usecstop = (unsigned long long)etstop.tv_sec * 1000000 + etstop.tv_usec;

  /* Display output */
  print_B();

  /* Display timing results */
  printf("\nElapsed time = %g ms.\n",
	 (float)(usecstop - usecstart)/(float)1000);

  printf("(CPU times are accurate to the nearest %g ms)\n",
	 1.0/(float)CLOCKS_PER_SEC * 1000.0);
  printf("My total CPU time for parent = %g ms.\n",
	 (float)( (cputstop.tms_utime + cputstop.tms_stime) -
		  (cputstart.tms_utime + cputstart.tms_stime) ) /
	 (float)CLOCKS_PER_SEC * 1000);
  printf("My system CPU time for parent = %g ms.\n",
	 (float)(cputstop.tms_stime - cputstart.tms_stime) /
	 (float)CLOCKS_PER_SEC * 1000);
  printf("My total CPU time for child processes = %g ms.\n",
	 (float)( (cputstop.tms_cutime + cputstop.tms_cstime) -
		  (cputstart.tms_cutime + cputstart.tms_cstime) ) /
	 (float)CLOCKS_PER_SEC * 1000);
      /* Contrary to the man pages, this appears not to include the parent */
  printf("--------------------------------------------\n");

  exit(0);
}

/* ------------------ Above Was Provided --------------------- */

/****** You will replace this routine with your own parallel version *******/
/* Provided global variables are MAXN, N, A[][] and B[][],
 * defined in the beginning of this code.  B[][] is initialized to zeros.
 */

 #define CHECK_ERR(x)                                    \
   if (x != cudaSuccess) {                               \
     fprintf(stderr,"%s in %s at line %d\n",             \
 	    cudaGetErrorString(err),__FILE__,__LINE__);	\
     exit(-1);						\
  }                                                    \

  __global__ void normCalc (float* d_A, float* d_B, float* d_mu, float* d_sigma, int n) {
    int col = blockDim.x * blockIdx.x + threadIdx.x;
    int row = blockDim.y * blockIdx.y + threadIdx.y;
    if (col < n && row < n) {
        //for (row=0; row < n; row++)
            d_B[row*n+col] = d_A[row*n+col];
    }
}


void matrixNorm() {

    printf("Computing in Parallel\n");

    cudaError_t err;

    float mu[N];
    float sigma[N];
    memset(mu, 0.0, sizeof(mu));
    memset(sigma, 0.0, sizeof(sigma));

    float *d_A, *d_B, *d_mu, *d_sigma;

    err = cudaMalloc((void **) &d_A, sizeof(float)*N*N);
    CHECK_ERR(err);
    err = cudaMalloc((void **) &d_B, sizeof(float)*N*N);
    CHECK_ERR(err);
    err = cudaMalloc((void **) &d_mu, sizeof(float)*N*N);
    CHECK_ERR(err);
    err = cudaMalloc((void **) &d_sigma, sizeof(float)*N*N);
    CHECK_ERR(err);


    err = cudaMemcpy(d_A, A, sizeof(float)*N*N, cudaMemcpyHostToDevice);
    CHECK_ERR(err);

    err = cudaMemcpy(d_mu, mu, sizeof(float)*N*N, cudaMemcpyHostToDevice);
    CHECK_ERR(err);

    err = cudaMemcpy(d_sigma, sigma, sizeof(float)*N*N, cudaMemcpyHostToDevice);
    CHECK_ERR(err);

    dim3 BlockSize(1,1);
    dim3 GridSize(N/BlockSize.x, N/BlockSize.y);
    normCalc<<<GridSize,BlockSize>>>(d_A, d_B, d_mu, d_sigma, N);

    err = cudaMemcpy(B, (d_B), sizeof(float)*N*N, cudaMemcpyDeviceToHost);
    CHECK_ERR(err);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_mu);
    cudaFree(d_sigma);

}
