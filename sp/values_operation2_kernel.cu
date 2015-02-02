//
// auto-generated by op2.py on 2015-02-02 17:49
//

//user function
__device__
#include "values_operation2.h"

// CUDA kernel function
__global__ void op_cuda_values_operation2(
  float *arg0,
  const int *arg1,
  const int *arg2,
  const int *arg3,
  const int *arg4,
  int   offset_s,    
  int   set_size ) {
  
  float arg0_l[4];
  int   tid = threadIdx.x%OP_WARPSIZE;
  
  extern __shared__ char shared[];
  char *arg_s = shared + offset_s*(threadIdx.x/OP_WARPSIZE);
  
  //process set elements
  for ( int n=threadIdx.x+blockIdx.x*blockDim.x; n<set_size; n = n+=blockDim.x*gridDim.x ){
    int offset = n - tid;
    int nelems = MIN(OP_WARPSIZE,set_size-offset);
    //copy data into shared memory, then into local
    for ( int m=0; m<4; m++ ){
      ((float *)arg_s)[tid+m*nelems] = arg0[tid+m*nelems+offset*4];
    }
    
    for ( int m=0; m<4; m++ ){
      arg0_l[m] = ((float *)arg_s)[m+tid*4];
    }
    
    
    //user-supplied kernel call
    values_operation2(arg0_l,
                      arg1,
                      arg2,
                      arg3,
                      arg4);
    //copy back into shared memory, then to device
    
    for ( int m=0; m<4; m++ ){
      ((float *)arg_s)[m+tid*4] = arg0_l[m];
    }
    for ( int m=0; m<4; m++ ){
      arg0[tid+m*nelems+offset*4] = ((float *)arg_s)[tid+m*nelems];
    }
  }
}


//host stub function
void op_par_loop_values_operation2(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3,
  op_arg arg4){
  
  int*arg1h = (int *)arg1.data;
  int*arg2h = (int *)arg2.data;
  int*arg3h = (int *)arg3.data;
  int*arg4h = (int *)arg4.data;
  int nargs = 5;
  op_arg args[5];
  
  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  
  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  values_operation2");
  }
  
  op_mpi_halo_exchanges_cuda(set, nargs, args);
  
  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timers_core(&cpu_t1, &wall_t1);
  
  if (set->size > 0) {
    
    op_timing_realloc(7);
    OP_kernels[7].name      = name;
    OP_kernels[7].count    += 1;
    
    //transfer constants to GPU
    int consts_bytes = 0;
    consts_bytes += ROUND_UP(1*sizeof(int));
    consts_bytes += ROUND_UP(1*sizeof(int));
    consts_bytes += ROUND_UP(1*sizeof(int));
    consts_bytes += ROUND_UP(1*sizeof(int));
    reallocConstArrays(consts_bytes);
    consts_bytes = 0;
    arg1.data   = OP_consts_h + consts_bytes;
    arg1.data_d = OP_consts_d + consts_bytes;
    for ( int d=0; d<1; d++ ){
      ((int *)arg1.data)[d] = arg1h[d];
    }
    consts_bytes += ROUND_UP(1*sizeof(int));
    arg2.data   = OP_consts_h + consts_bytes;
    arg2.data_d = OP_consts_d + consts_bytes;
    for ( int d=0; d<1; d++ ){
      ((int *)arg2.data)[d] = arg2h[d];
    }
    consts_bytes += ROUND_UP(1*sizeof(int));
    arg3.data   = OP_consts_h + consts_bytes;
    arg3.data_d = OP_consts_d + consts_bytes;
    for ( int d=0; d<1; d++ ){
      ((int *)arg3.data)[d] = arg3h[d];
    }
    consts_bytes += ROUND_UP(1*sizeof(int));
    arg4.data   = OP_consts_h + consts_bytes;
    arg4.data_d = OP_consts_d + consts_bytes;
    for ( int d=0; d<1; d++ ){
      ((int *)arg4.data)[d] = arg4h[d];
    }
    consts_bytes += ROUND_UP(1*sizeof(int));
    mvConstArraysToDevice(consts_bytes);
    
    //set CUDA execution parameters
    #ifdef OP_BLOCK_SIZE_7
      int nthread = OP_BLOCK_SIZE_7;
    #else
    //  int nthread = OP_block_size;
      int nthread = 128;
    #endif
    
    int nblocks = 200;
    
    //work out shared memory requirements per element
    
    int nshared = 0;
    nshared = MAX(nshared,sizeof(float)*4);
    
    //execute plan
    int offset_s = nshared*OP_WARPSIZE;
    
    nshared = nshared*nthread;
    op_cuda_values_operation2<<<nblocks,nthread,nshared>>>(
      (float *) arg0.data_d,
      (int *) arg1.data_d,
      (int *) arg2.data_d,
      (int *) arg3.data_d,
      (int *) arg4.data_d,
      offset_s,
      set->size );
  }
  op_mpi_set_dirtybit_cuda(nargs, args);
  //update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[7].time     += wall_t2 - wall_t1;
  OP_kernels[7].transfer += (float)set->size * arg0.size * 2.0f;
}
