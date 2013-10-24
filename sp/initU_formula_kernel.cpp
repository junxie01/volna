//
// auto-generated by op2.py on 2013-10-24 17:48
//

//user function
#include "initU_formula.h"

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

  // initialise timers
  double cpu_t1, cpu_t2, wall_t1, wall_t2;
  op_timing_realloc(5);
  op_timers_core(&cpu_t1, &wall_t1);


  if (OP_diags>2) {
    printf(" kernel routine w/o indirection:  initU_formula");
  }

  op_mpi_halo_exchanges(set, nargs, args);
  // set number of threads
  #ifdef _OPENMP
    int nthreads = omp_get_max_threads();
  #else
    int nthreads = 1;
  #endif

  if (set->size >0) {

    // execute plan
    #pragma omp parallel for
    for ( int thr=0; thr<nthreads; thr++ ){
      int start  = (set->size* thr)/nthreads;
      int finish = (set->size*(thr+1))/nthreads;
      for ( int n=start; n<finish; n++ ){
        initU_formula(
          &((float*)arg0.data)[2*n],
          &((float*)arg1.data)[4*n],
          &arg2_l[64*omp_get_thread_num()]);
      }
    }
  }

  // combine reduction data
  op_mpi_set_dirtybit(nargs, args);

  // update kernel record
  op_timers_core(&cpu_t2, &wall_t2);
  OP_kernels[5].name      = name;
  OP_kernels[5].count    += 1;
  OP_kernels[5].time     += wall_t2 - wall_t1;
  OP_kernels[5].transfer += (float)set->size * arg0.size;
  OP_kernels[5].transfer += (float)set->size * arg1.size * 2.0f;
}
