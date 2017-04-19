//
// auto-generated by op2.py on 2015-02-02 17:49
//

//user function
__device__
#include "initBathymetry_formula.h"

// CUDA kernel function
__global__ void op_cuda_initBathymetry_formula(
  float *arg0,
  float *arg1,
  const double *arg2,
  int   offset_s,    
  int   set_size ) {
  
  float arg0_l[2];
  float arg1_l[4];
  int   tid = threadIdx.x%OP_WARPSIZE;
  
  extern __shared__ char shared[];
  char *arg_s = shared + offset_s*(threadIdx.x/OP_WARPSIZE);
  
  //process set elements
  for ( int n=threadIdx.x+blockIdx.x*blockDim.x; n<set_size; n = n+=blockDim.x*gridDim.x ){
    int offset = n - tid;
    int nelems = MIN(OP_WARPSIZE,set_size-offset);
    //copy data into shared memory, then into local
    for ( int m=0; m<2; m++ ){
      ((float *)arg_s)[tid+m*nelems] = arg0[tid+m*nelems+offset*2];
    }
    
    for ( int m=0; m<2; m++ ){
      arg0_l[m] = ((float *)arg_s)[m+tid*2];
    }
    
    for ( int m=0; m<4; m++ ){
      ((float *)arg_s)[tid+m*nelems] = arg1[tid+m*nelems+offset*4];
    }
    
    for ( int m=0; m<4; m++ ){
      arg1_l[m] = ((float *)arg_s)[m+tid*4];
    }
    
    
    //user-supplied kernel call
    initBathymetry_formula(arg0_l,
                           arg1_l,
                           arg2);
    //copy back into shared memory, then to device
    
    for ( int m=0; m<4; m++ ){
      ((float *)arg_s)[m+tid*4] = arg1_l[m];
    }
    for ( int m=0; m<4; m++ ){
      arg1[tid+m*nelems+offset*4] = ((float *)arg_s)[tid+m*nelems];
    }
  }
}


//host stub function
void op_par_loop_initBathymetry_formula(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2){
  
  double*arg2h = (double *)arg2.data;
  int nargs = 3;
  op_arg args[3];
  
  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  
  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  initBathymetry_formula");
  }
  
  op_mpi_halo_exchanges_cuda(set, nargs, args);
  
  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timers_core(&cpu_t1, &wall_t1);
  
  if (set->size > 0) {
    
    op_timing_realloc(11);
    OP_kernels[11].name      = name;
    OP_kernels[11].count    += 1;
    
    //transfer constants to GPU
    int consts_bytes = 0;
    consts_bytes += ROUND_UP(1*sizeof(double));
    reallocConstArrays(consts_bytes);
    consts_bytes = 0;
    arg2.data   = OP_consts_h + consts_bytes;
    arg2.data_d = OP_consts_d + consts_bytes;
    for ( int d=0; d<1; d++ ){
      ((double *)arg2.data)[d] = arg2h[d];
    }
    consts_bytes += ROUND_UP(1*sizeof(double));
    mvConstArraysToDevice(consts_bytes);
    
    //set CUDA execution parameters
    #ifdef OP_BLOCK_SIZE_11
      int nthread = OP_BLOCK_SIZE_11;
    #else
    //  int nthread = OP_block_size;
      int nthread = 128;
    #endif
    
    int nblocks = 200;
    
    //work out shared memory requirements per element
    
    int nshared = 0;
    nshared = MAX(nshared,sizeof(float)*2);
    nshared = MAX(nshared,sizeof(float)*4);
    
    //execute plan
    int offset_s = nshared*OP_WARPSIZE;
    
    nshared = nshared*nthread;
    op_cuda_initBathymetry_formula<<<nblocks,nthread,nshared>>>(
      (float *) arg0.data_d,
      (float *) arg1.data_d,
      (double *) arg2.data_d,
      offset_s,
      set->size );
  } else
    op_mpi_wait_all_cuda(nargs, args);
  op_mpi_set_dirtybit_cuda(nargs, args);
  //update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[11].time     += wall_t2 - wall_t1;
  OP_kernels[11].transfer += (float)set->size * arg0.size;
  OP_kernels[11].transfer += (float)set->size * arg1.size * 2.0f;
}
