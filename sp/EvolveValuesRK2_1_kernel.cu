//
// auto-generated by op2.py on 2013-10-24 17:48
//

//user function
__device__
#include "EvolveValuesRK2_1.h"

// CUDA kernel function
__global__ void op_cuda_EvolveValuesRK2_1(
  const float *arg0,
  float *arg1,
  float *arg2,
  float *arg3,
  float *arg4,
  int   offset_s,
  int   set_size ) {

  float arg1_l[4];
  float arg2_l[4];
  float arg3_l[4];
  float arg4_l[4];
  int   tid = threadIdx.x%OP_WARPSIZE;

  extern __shared__ char shared[];
  char *arg_s = shared + offset_s*(threadIdx.x/OP_WARPSIZE);

  //process set elements
  for ( int n=threadIdx.x+blockIdx.x*blockDim.x; n<set_size; n = n+=blockDim.x*gridDim.x ){
    int offset = n - tid;
    int nelems = MIN(OP_WARPSIZE,set_size-offset);
    //copy data into shared memory, then into local
    for ( int m=0; m<4; m++ ){
      ((float *)arg_s)[tid+m*nelems] = arg1[tid+m*nelems+offset*4];
    }

    for ( int m=0; m<4; m++ ){
      arg1_l[m] = ((float *)arg_s)[m+tid*4];
    }

    for ( int m=0; m<4; m++ ){
      ((float *)arg_s)[tid+m*nelems] = arg2[tid+m*nelems+offset*4];
    }

    for ( int m=0; m<4; m++ ){
      arg2_l[m] = ((float *)arg_s)[m+tid*4];
    }


    //user-supplied kernel call
    EvolveValuesRK2_1(arg0,
                      arg1_l,
                      arg2_l,
                      arg3_l,
                      arg4_l);
    //copy back into shared memory, then to device

    for ( int m=0; m<4; m++ ){
      ((float *)arg_s)[m+tid*4] = arg1_l[m];
    }
    for ( int m=0; m<4; m++ ){
      arg1[tid+m*nelems+offset*4] = ((float *)arg_s)[tid+m*nelems];
    }

    for ( int m=0; m<4; m++ ){
      ((float *)arg_s)[m+tid*4] = arg3_l[m];
    }
    for ( int m=0; m<4; m++ ){
      arg3[tid+m*nelems+offset*4] = ((float *)arg_s)[tid+m*nelems];
    }

    for ( int m=0; m<4; m++ ){
      ((float *)arg_s)[m+tid*4] = arg4_l[m];
    }
    for ( int m=0; m<4; m++ ){
      arg4[tid+m*nelems+offset*4] = ((float *)arg_s)[tid+m*nelems];
    }
  }
}


//host stub function
void op_par_loop_EvolveValuesRK2_1(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3,
  op_arg arg4){

  float*arg0h = (float *)arg0.data;
  int nargs = 5;
  op_arg args[5];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;

  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  EvolveValuesRK2_1");
  }

  op_mpi_halo_exchanges(set, nargs, args);

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timers_core(&cpu_t1, &wall_t1);

  if (set->size > 0) {

    op_timing_realloc(0);
    OP_kernels[0].name      = name;
    OP_kernels[0].count    += 1;

    //transfer constants to GPU
    int consts_bytes = 0;
    consts_bytes += ROUND_UP(1*sizeof(float));
    reallocConstArrays(consts_bytes);
    consts_bytes = 0;
    arg0.data   = OP_consts_h + consts_bytes;
    arg0.data_d = OP_consts_d + consts_bytes;
    for ( int d=0; d<1; d++ ){
      ((float *)arg0.data)[d] = arg0h[d];
    }
    consts_bytes += ROUND_UP(1*sizeof(float));
    mvConstArraysToDevice(consts_bytes);

    //set CUDA execution parameters
    #ifdef OP_BLOCK_SIZE_0
      int nthread = OP_BLOCK_SIZE_0;
    #else
    //  int nthread = OP_block_size;
      int nthread = 128;
    #endif

    int nblocks = 200;

    //work out shared memory requirements per element

    int nshared = 0;
    nshared = MAX(nshared,sizeof(float)*4);
    nshared = MAX(nshared,sizeof(float)*4);
    nshared = MAX(nshared,sizeof(float)*4);
    nshared = MAX(nshared,sizeof(float)*4);

    //execute plan
    int offset_s = nshared*OP_WARPSIZE;

    nshared = nshared*nthread;
    op_cuda_EvolveValuesRK2_1<<<nblocks,nthread,nshared>>>(
      (float *) arg0.data_d,
      (float *) arg1.data_d,
      (float *) arg2.data_d,
      (float *) arg3.data_d,
      (float *) arg4.data_d,
      offset_s,
      set->size );
  }
  op_mpi_set_dirtybit(nargs, args);
  //update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[0].time     += wall_t2 - wall_t1;
  OP_kernels[0].transfer += (float)set->size * arg1.size * 2.0f;
  OP_kernels[0].transfer += (float)set->size * arg2.size;
  OP_kernels[0].transfer += (float)set->size * arg3.size;
  OP_kernels[0].transfer += (float)set->size * arg4.size;
}
