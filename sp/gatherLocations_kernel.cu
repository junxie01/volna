//
// auto-generated by op2.py on 2015-02-02 17:49
//

//user function
__device__
#include "gatherLocations.h"

// CUDA kernel function
__global__ void op_cuda_gatherLocations(
  float *ind_arg0,
  int   *ind_map,
  short *arg_map,
  float  *arg1,
  int   *ind_arg_sizes,
  int   *ind_arg_offs, 
  int    block_offset, 
  int   *blkmap,       
  int   *offset,       
  int   *nelems,       
  int   *ncolors,      
  int   *colors,       
  int   nblocks,       
  int   set_size) {    
  
  __shared__  int  *ind_arg0_map, ind_arg0_size;
  __shared__  float *ind_arg0_s;
  __shared__ int    nelem, offset_b;
  
  extern __shared__ char shared[];
  
  if (blockIdx.x+blockIdx.y*gridDim.x >= nblocks) {
    return;
  }
  if (threadIdx.x==0) {
    
    //get sizes and shift pointers and direct-mapped data
    
    int blockId = blkmap[blockIdx.x + blockIdx.y*gridDim.x  + block_offset];
    
    nelem    = nelems[blockId];
    offset_b = offset[blockId];
    
    ind_arg0_size = ind_arg_sizes[0+blockId*1];
    
    ind_arg0_map = &ind_map[0*set_size] + ind_arg_offs[0+blockId*1];
    
    //set shared memory pointers
    int nbytes = 0;
    ind_arg0_s = (float *) &shared[nbytes];
  }
  __syncthreads(); // make sure all of above completed
  
  //copy indirect datasets into shared memory or zero increment
  
  for ( int n=threadIdx.x; n<ind_arg0_size*4; n = n+=blockDim.x ){
    ind_arg0_s[n] = ind_arg0[n%4+ind_arg0_map[n/4]*4];
    
  }
  
  __syncthreads();
  //process set elements
  
  for ( int n=threadIdx.x; n<nelem; n = n+=blockDim.x ){
    
    //user-supplied kernel call
    gatherLocations(ind_arg0_s+arg_map[0*set_size+n+offset_b]*4,
                    arg1+(n+offset_b)*1);
  }
}


//host stub function
void op_par_loop_gatherLocations(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1){
  
  int nargs = 2;
  op_arg args[2];
  
  args[0] = arg0;
  args[1] = arg1;
  
  int    ninds   = 1;
    int    inds[2] = {0,-1};
  
  if (OP_diags>2) {
    printf(" kernel routine with indirection: gatherLocations\n");
  }
  
  //get plan
  #ifdef OP_PART_SIZE_17
    int part_size = OP_PART_SIZE_17;
  #else
    int part_size = OP_part_size;
  #endif
  
  int set_size = op_mpi_halo_exchanges_cuda(set, nargs, args);
  
  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timers_core(&cpu_t1, &wall_t1);
  
  if (set->size > 0) {
    
    op_timing_realloc(17);
    OP_kernels[17].name      = name;
    OP_kernels[17].count    += 1;
    
    op_plan *Plan = op_plan_get(name,set,part_size,nargs,args,ninds,inds);
    
    //execute plan
    
    int block_offset = 0;
    for ( int col=0; col<Plan->ncolors; col++ ){
      if (col==Plan->ncolors_core) {
        op_mpi_wait_all_cuda(nargs, args);
      }
      #ifdef OP_BLOCK_SIZE_17
      int nthread = OP_BLOCK_SIZE_17;
      #else
      int nthread = OP_block_size;
      #endif
      
      dim3 nblocks = dim3(Plan->ncolblk[col] >= (1<<16) ? 65535 : Plan->ncolblk[col],
      Plan->ncolblk[col] >= (1<<16) ? (Plan->ncolblk[col]-1)/65535+1: 1, 1);
      if (Plan->ncolblk[col] > 0) {
        int nshared = Plan->nsharedCol[col];
        op_cuda_gatherLocations<<<nblocks,nthread,nshared>>>(
        (float *)arg0.data_d,
        Plan->ind_map,
        Plan->loc_map,
        (float*)arg1.data_d,
        Plan->ind_sizes,
        Plan->ind_offs,
        block_offset,
        Plan->blkmap,
        Plan->offset,
        Plan->nelems,
        Plan->nthrcol,
        Plan->thrcol,
        Plan->ncolblk[col],
        set_size);
        
      }
      block_offset += Plan->ncolblk[col];
    }
    OP_kernels[17].transfer  += Plan->transfer;
    OP_kernels[17].transfer2 += Plan->transfer2;
  }
  op_mpi_set_dirtybit_cuda(nargs, args);
  //update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[17].time     += wall_t2 - wall_t1;
}
