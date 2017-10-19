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
