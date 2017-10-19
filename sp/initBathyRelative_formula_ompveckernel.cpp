//
// auto-generated by op2.py
//

//user function
inline void initBathyRelative_formula(const float *coords, float *values, const float *bathy0, const double *time) {
  float x = coords[0];
  float y = coords[1];
  float t = *time;
  float val = exp(-(2.f*sqrt(x*0.01f*0.01f/(tan((5.7f*2.f*M_PI)/360.f)))-sqrt(g)*0.01f*t)*(2.f*sqrt(x*0.01f*0.01f/(tan((5.7f*2.f*M_PI)/360.f)))-sqrt(g)*0.01f*t));;
  values[3] = *bathy0 + val;
}

// host stub function
void op_par_loop_initBathyRelative_formula(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2,
  op_arg arg3){

  int nargs = 4;
  op_arg args[4];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  //create aligned pointers for dats
  ALIGNED_float const float * __restrict__ ptr0 = (float *) arg0.data;
  __assume_aligned(ptr0,float_ALIGN);
  ALIGNED_float       float * __restrict__ ptr1 = (float *) arg1.data;
  __assume_aligned(ptr1,float_ALIGN);
  ALIGNED_float const float * __restrict__ ptr2 = (float *) arg2.data;
  __assume_aligned(ptr2,float_ALIGN);

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timing_realloc(17);
  op_timers_core(&cpu_t1, &wall_t1);


  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  initBathyRelative_formula");
  }

  int set_size = op_mpi_halo_exchanges(set, nargs, args);

  if (set_size >0) {

    #ifdef VECTORIZE
    #pragma novector
    #pragma omp parallel for
    for ( int n=0; n<(set_size/SIMD_VEC)*SIMD_VEC; n+=SIMD_VEC ){
      #pragma omp simd aligned(ptr0,ptr1,ptr2)
      for ( int i=0; i<SIMD_VEC; i++ ){
        initBathyRelative_formula(
          &(ptr0)[2 * (n+i)],
          &(ptr1)[4 * (n+i)],
          &(ptr2)[1 * (n+i)],
          (double*)arg3.data);
      }
    }
    //remainder
    for ( int n=(set_size/SIMD_VEC)*SIMD_VEC; n<set_size; n++ ){
    #else
    #pragma omp parallel for simd aligned(ptr0,ptr1,ptr2)
    for ( int n=0; n<set_size; n++ ){
    #endif
      initBathyRelative_formula(
        &(ptr0)[2*n],
        &(ptr1)[4*n],
        &(ptr2)[1*n],
        (double*)arg3.data);
    }
  }

  // combine reduction data
  op_mpi_set_dirtybit(nargs, args);

  // update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[17].name      = name;
  OP_kernels[17].count    += 1;
  OP_kernels[17].time     += wall_t2 - wall_t1;
  OP_kernels[17].transfer += (float)set->size * arg0.size;
  OP_kernels[17].transfer += (float)set->size * arg1.size * 2.0f;
  OP_kernels[17].transfer += (float)set->size * arg2.size;
}
#undef VECTORIZE
