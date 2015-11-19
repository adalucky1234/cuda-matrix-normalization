# Cuda Matrix Normalization

To run the project, you probably will need a Nvidia GPU and the CUDA Toolkit.


You can run the makefile to compile.

```sh
$ make
```

Or you can compile separated:

```sh
$ cc matrixNorm.c -o norm.out
$ nvcc matrixNorm.cu -o gpunorm.out
```

And then just run the program:

```sh
Usage: ./norm.out <matrix_dimension> [random seed]
Usage: ./gpunorm.out <matrix_dimension> [random seed]
```
