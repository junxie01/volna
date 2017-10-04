//
// auto-generated by op2.py
//

//user function
__device__ void applyConst_gpu( const float *in, float *out, const int *variables) {
  if (*variables & 1) {
    out[0] = *in;

  }
  if (*variables & 2) {
    out[1] = *in;

  }
  if (*variables & 4) {
    out[2] = *in;

  }
  if (*variables & 8) {
    out[3] = *in;

  }
}

// CUDA kernel function
__global__ void op_cuda_applyConst(
  const float *__restrict arg0,
  float *arg1,
  const int *arg2,
  int   set_size ) {


  //process set elements
  for ( int n=threadIdx.x+blockIdx.x*blockDim.x; n<set_size; n+=blockDim.x*gridDim.x ){

    //user-supplied kernel call
    applyConst_gpu(arg0+n*1,
               arg1+n*4,
               arg2);
  }
}


//host stub function
void op_par_loop_applyConst(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2){

  int*arg2h = (int *)arg2.data;
  int nargs = 3;
  op_arg args[3];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timing_realloc(15);
  op_timers_core(&cpu_t1, &wall_t1);
  OP_kernels[15].name      = name;
  OP_kernels[15].count    += 1;


  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  applyConst");
  }

  op_mpi_halo_exchanges_cuda(set, nargs, args);
  if (set->size > 0) {

    //transfer constants to GPU
    int consts_bytes = 0;
    consts_bytes += ROUND_UP(1*sizeof(int));
    reallocConstArrays(consts_bytes);
    consts_bytes = 0;
    arg2.data   = OP_consts_h + consts_bytes;
    arg2.data_d = OP_consts_d + consts_bytes;
    for ( int d=0; d<1; d++ ){
      ((int *)arg2.data)[d] = arg2h[d];
    }
    consts_bytes += ROUND_UP(1*sizeof(int));
    mvConstArraysToDevice(consts_bytes);

    //set CUDA execution parameters
    #ifdef OP_BLOCK_SIZE_15
      int nthread = OP_BLOCK_SIZE_15;
    #else
      int nthread = OP_block_size;
    //  int nthread = 128;
    #endif

    int nblocks = 200;

    op_cuda_applyConst<<<nblocks,nthread>>>(
      (float *) arg0.data_d,
      (float *) arg1.data_d,
      (int *) arg2.data_d,
      set->size );
  }
  op_mpi_set_dirtybit_cuda(nargs, args);
  cutilSafeCall(cudaDeviceSynchronize());
  //update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[15].time     += wall_t2 - wall_t1;
  OP_kernels[15].transfer += (float)set->size * arg0.size;
  OP_kernels[15].transfer += (float)set->size * arg1.size * 2.0f;
}
