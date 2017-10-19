//
// auto-generated by op2.py
//

//user function
inline void SpaceDiscretization(float *left, //OP_INC
              float *right, //OP_INC
              const float *edgeFluxes, //OP_READ
              const float *bathySource, //OP_READ
              const float *edgeNormals, const int *isRightBoundary, 
              const float *cellVolumes0, //OP_READ
              const float *cellVolumes1 //OP_READ
)
{
  left[0] -= (edgeFluxes[0])/cellVolumes0[0];
  left[1] -= (edgeFluxes[1] + bathySource[0] * edgeNormals[0])/cellVolumes0[0];
  left[2] -= (edgeFluxes[2] + bathySource[0] * edgeNormals[1])/cellVolumes0[0];

  if (!isRightBoundary[0]) {
    right[0] += edgeFluxes[0]/cellVolumes1[0];
    right[1] += (edgeFluxes[1] + bathySource[1] * edgeNormals[0])/cellVolumes1[0];
    right[2] += (edgeFluxes[2] + bathySource[1] * edgeNormals[1])/cellVolumes1[0];
  }
}
#define VECTORIZE
#ifdef VECTORIZE
//user function -- modified for vectorisation
void SpaceDiscretization_vec( float left[*][SIMD_VEC], float right[*][SIMD_VEC], const float *edgeFluxes, const float *bathySource, const float *edgeNormals, const int *isRightBoundary, const float cellVolumes0[*][SIMD_VEC], const float cellVolumes1[*][SIMD_VEC], int idx ) {
  left[0][idx] -= (edgeFluxes[0])/cellVolumes0[0][idx];
  left[1][idx] -= (edgeFluxes[1] + bathySource[0] * edgeNormals[0])/cellVolumes0[0][idx];
  left[2][idx] -= (edgeFluxes[2] + bathySource[0] * edgeNormals[1])/cellVolumes0[0][idx];

  if (!isRightBoundary[0]) {
    right[0][idx] += edgeFluxes[0]/cellVolumes1[0][idx];
    right[1][idx] += (edgeFluxes[1] + bathySource[1] * edgeNormals[0])/cellVolumes1[0][idx];
    right[2][idx] += (edgeFluxes[2] + bathySource[1] * edgeNormals[1])/cellVolumes1[0][idx];
  }
}
#endif

// host stub function
void op_par_loop_SpaceDiscretization(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3,
  op_arg arg4,
  op_arg arg5,
  op_arg arg6,
  op_arg arg7){

  int nargs = 8;
  op_arg args[8];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  args[5] = arg5;
  args[6] = arg6;
  args[7] = arg7;
  //create aligned pointers for dats
  ALIGNED_float       float * __restrict__ ptr0 = (float *) arg0.data;
  __assume_aligned(ptr0,float_ALIGN);
  ALIGNED_float       float * __restrict__ ptr1 = (float *) arg1.data;
  __assume_aligned(ptr1,float_ALIGN);
  ALIGNED_float const float * __restrict__ ptr2 = (float *) arg2.data;
  __assume_aligned(ptr2,float_ALIGN);
  ALIGNED_float const float * __restrict__ ptr3 = (float *) arg3.data;
  __assume_aligned(ptr3,float_ALIGN);
  ALIGNED_float const float * __restrict__ ptr4 = (float *) arg4.data;
  __assume_aligned(ptr4,float_ALIGN);
  ALIGNED_int const int * __restrict__ ptr5 = (int *) arg5.data;
  __assume_aligned(ptr5,int_ALIGN);
  ALIGNED_float const float * __restrict__ ptr6 = (float *) arg6.data;
  __assume_aligned(ptr6,float_ALIGN);
  ALIGNED_float const float * __restrict__ ptr7 = (float *) arg7.data;
  __assume_aligned(ptr7,float_ALIGN);

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timing_realloc(5);
  op_timers_core(&cpu_t1, &wall_t1);

  int  ninds   = 2;
  int  inds[8] = {0,0,-1,-1,-1,-1,1,1};

  if (OP_diags>2) {
    printf(" kernel routine with indirection: SpaceDiscretization\n");
  }

  #ifdef OP_PART_SIZE_5
    int part_size = OP_PART_SIZE_5;
  #else
    int part_size = OP_part_size;
  #endif


  int set_size = op_mpi_halo_exchanges(set, nargs, args);

  if (set_size >0) {

    // get plan
    op_plan *Plan = op_plan_get_stage_upload(name,set,part_size,nargs,args,ninds,inds,OP_STAGE_ALL,0);

    // execute plan
    int block_offset = 0;
    for ( int col=0; col<Plan->ncolors; col++ ){
      if (col==Plan->ncolors_core) {
        op_mpi_wait_all(nargs, args);
      }
      int nblocks = Plan->ncolblk[col];

      #pragma omp parallel for
      for ( int blockIdx=0; blockIdx<nblocks; blockIdx++ ){
        int blockId  = Plan->blkmap[blockIdx + block_offset];
        int nelem    = Plan->nelems[blockId];
        int offset_b = Plan->offset[blockId];
        #ifdef VECTORIZE
        //peel left remainder
        for ( int n=offset_b; n<((offset_b-1)/SIMD_VEC+1)*SIMD_VEC; n++ ){
          int map0idx = arg0.map_data[n * arg0.map->dim + 0];
          int map1idx = arg0.map_data[n * arg0.map->dim + 1];

          SpaceDiscretization(
            &(ptr0)[4 * map0idx],
            &(ptr1)[4 * map1idx],
            &(ptr2)[3 * n],
            &(ptr3)[2 * n],
            &(ptr4)[2 * n],
            &(ptr5)[1 * n],
            &(ptr6)[1 * map0idx],
            &(ptr7)[1 * map1idx]);
        }
        #pragma novector
        for ( int n=((offset_b-1)/SIMD_VEC+1)*SIMD_VEC; n<((offset_b+nelem)/SIMD_VEC)*SIMD_VEC; n+=SIMD_VEC ){
          if (n+SIMD_VEC >= set->core_size) {
            op_mpi_wait_all(nargs, args);
          }
          ALIGNED_float float dat0[4][SIMD_VEC];
          ALIGNED_float float dat1[4][SIMD_VEC];
          ALIGNED_float float dat6[1][SIMD_VEC];
          ALIGNED_float float dat7[1][SIMD_VEC];
          #pragma omp simd aligned(ptr0,ptr1,ptr2,ptr3,ptr4,ptr5,ptr6,ptr7)
          for ( int i=0; i<SIMD_VEC; i++ ){
            int idx6_1 = 1 * arg0.map_data[(n+i) * arg0.map->dim + 0];
            int idx7_1 = 1 * arg0.map_data[(n+i) * arg0.map->dim + 1];

            dat0[0][i] = 0.0;
            dat0[1][i] = 0.0;
            dat0[2][i] = 0.0;
            dat0[3][i] = 0.0;

            dat1[0][i] = 0.0;
            dat1[1][i] = 0.0;
            dat1[2][i] = 0.0;
            dat1[3][i] = 0.0;

            dat6[0][i] = (ptr6)[idx6_1 + 0];

            dat7[0][i] = (ptr7)[idx7_1 + 0];

          }
          #pragma omp simd aligned(ptr0,ptr1,ptr2,ptr3,ptr4,ptr5,ptr6,ptr7)
          for ( int i=0; i<SIMD_VEC; i++ ){
            SpaceDiscretization_vec(
              dat0,
              dat1,
              &(ptr2)[3 * (n+i)],
              &(ptr3)[2 * (n+i)],
              &(ptr4)[2 * (n+i)],
              &(ptr5)[1 * (n+i)],
              dat6,
              dat7,
              i);
          }
          for ( int i=0; i<SIMD_VEC; i++ ){
            int idx0_4 = 4 * arg0.map_data[(n+i) * arg0.map->dim + 0];
            int idx1_4 = 4 * arg0.map_data[(n+i) * arg0.map->dim + 1];

            (ptr0)[idx0_4 + 0] += dat0[0][i];
            (ptr0)[idx0_4 + 1] += dat0[1][i];
            (ptr0)[idx0_4 + 2] += dat0[2][i];
            (ptr0)[idx0_4 + 3] += dat0[3][i];

            (ptr1)[idx1_4 + 0] += dat1[0][i];
            (ptr1)[idx1_4 + 1] += dat1[1][i];
            (ptr1)[idx1_4 + 2] += dat1[2][i];
            (ptr1)[idx1_4 + 3] += dat1[3][i];

          }
        }

        //remainder
        for ( int n=((offset_b+nelem)/SIMD_VEC)*SIMD_VEC; n<offset_b+nelem; n++ ){
        #else
        for ( int n=offset_b; n<offset_b+nelem; n++ ){
        #endif
          int map0idx = arg0.map_data[n * arg0.map->dim + 0];
          int map1idx = arg0.map_data[n * arg0.map->dim + 1];

          SpaceDiscretization(
            &(ptr0)[4 * map0idx],
            &(ptr1)[4 * map1idx],
            &(ptr2)[3 * n],
            &(ptr3)[2 * n],
            &(ptr4)[2 * n],
            &(ptr5)[1 * n],
            &(ptr6)[1 * map0idx],
            &(ptr7)[1 * map1idx]);
        }
      }
    }
  }

  if (set_size == 0 || set_size == set->core_size) {
    op_mpi_wait_all(nargs, args);
  }
  // combine reduction data
  op_mpi_set_dirtybit(nargs, args);

  // update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[5].name      = name;
  OP_kernels[5].count    += 1;
  OP_kernels[5].time     += wall_t2 - wall_t1;
  OP_kernels[5].transfer += (float)set->size * arg0.size * 2.0f;
  OP_kernels[5].transfer += (float)set->size * arg6.size;
  OP_kernels[5].transfer += (float)set->size * arg2.size;
  OP_kernels[5].transfer += (float)set->size * arg3.size;
  OP_kernels[5].transfer += (float)set->size * arg4.size;
  OP_kernels[5].transfer += (float)set->size * arg5.size;
  OP_kernels[5].transfer += (float)set->size * arg0.map->dim * 4.0f;
}
#undef VECTORIZE
