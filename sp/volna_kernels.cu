//
// auto-generated by op2.m on 09-Nov-2012 09:54:13
//

// header

#include "op_lib_cpp.h"

#include "op_cuda_rt_support.h"
#include "op_cuda_reduction.h"
// global constants

#ifndef MAX_CONST_SIZE
#define MAX_CONST_SIZE 128
#endif

__constant__ float CFL;
__constant__ float EPS;
__constant__ float g;

void op_decl_const_char(int dim, char const *type,
            int size, char *dat, char const *name) {
  if (!strcmp(name,"CFL")) {
    cutilSafeCall(cudaMemcpyToSymbol(CFL, dat, dim*size));
  } else  if (!strcmp(name,"EPS")) {
    cutilSafeCall(cudaMemcpyToSymbol(EPS, dat, dim*size));
  } else  if (!strcmp(name,"g")) {
    cutilSafeCall(cudaMemcpyToSymbol(g, dat, dim*size));
  } else {
    printf("error: unknown const name\n"); exit(1);
  }
}

// user kernel files

#include "EvolveValuesRK2_1_kernel.cu"
#include "EvolveValuesRK2_2_kernel.cu"
#include "simulation_1_kernel.cu"
#include "applyConst_kernel.cu"
#include "initEta_formula_kernel.cu"
#include "initU_formula_kernel.cu"
#include "initV_formula_kernel.cu"
#include "values_operation2_kernel.cu"
#include "initBathymetry_formula_kernel.cu"
#include "initBathymetry_update_kernel.cu"
#include "initBore_select_kernel.cu"
#include "initGaussianLandslide_kernel.cu"
#include "getTotalVol_kernel.cu"
#include "getMaxElevation_kernel.cu"
#include "gatherLocations_kernel.cu"
#include "computeFluxes_kernel.cu"
#include "NumericalFluxes_kernel.cu"
#include "SpaceDiscretization_kernel.cu"
