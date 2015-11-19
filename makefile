CC:=gcc
NVCC:=nvcc

program: matrixNorm.c matrixNorm.cu

	 $(CC) matrixNorm.c -o norm.out

	 $(NVCC) matrixNorm.cu -o gpunorm.out

clean:
	rm -rf *.out
