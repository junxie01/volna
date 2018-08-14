//
// auto-generated by op2.py
//

//user function
inline void initU_formula(const float *coords, float *values, const double *time) {
  float x = coords[0];
  float y = coords[1];
  float t = *time;
  float val =     0.0f  ;;
  values[1] += val;
}
// host stub function
void op_par_loop_initU_formula(char const *name, op_set set,
  op_arg arg0,
  op_arg arg1,
  op_arg arg2){

  int nargs = 3;
  op_arg args[3];

  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  //create aligned pointers for dats
  ALIGNED_float const float * __restrict__ ptr0 = (float *) arg0.data;
  __assume_aligned(ptr0,float_ALIGN);
  ALIGNED_float       float * __restrict__ ptr1 = (float *) arg1.data;
  __assume_aligned(ptr1,float_ALIGN);

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timing_realloc(16);
  op_timers_core(&cpu_t1, &wall_t1);


  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  initU_formula");
  }

  int exec_size = op_mpi_halo_exchanges(set, nargs, args);

  if (exec_size >0) {

    #ifdef VECTORIZE
    #pragma novector
    for ( int n=0; n<(exec_size/SIMD_VEC)*SIMD_VEC; n+=SIMD_VEC ){
      #pragma simd
      for ( int i=0; i<SIMD_VEC; i++ ){
        initU_formula(
          &(ptr0)[2 * (n+i)],
          &(ptr1)[4 * (n+i)],
          (double*)arg2.data);
      }
      for ( int i=0; i<SIMD_VEC; i++ ){
      }
    }
    //remainder
    for ( int n=(exec_size/SIMD_VEC)*SIMD_VEC; n<exec_size; n++ ){
    #else
    for ( int n=0; n<exec_size; n++ ){
    #endif
      initU_formula(
        &(ptr0)[2*n],
        &(ptr1)[4*n],
        (double*)arg2.data);
    }
  }

  // combine reduction data
  op_mpi_set_dirtybit(nargs, args);

  // update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[16].name      = name;
  OP_kernels[16].count    += 1;
  OP_kernels[16].time     += wall_t2 - wall_t1;
  OP_kernels[16].transfer += (float)set->size * arg0.size;
  OP_kernels[16].transfer += (float)set->size * arg1.size * 2.0f;
}