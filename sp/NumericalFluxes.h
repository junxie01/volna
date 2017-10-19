inline void NumericalFluxes(const float *maxEdgeEigenvalues0,
          const float *maxEdgeEigenvalues1, 
          const float *maxEdgeEigenvalues2, 
          const float *EdgeVolumes0,
          const float *EdgeVolumes1,
          const float *EdgeVolumes2,
          const float *cellVolumes, //OP_READ
            float *zeroInit, float *minTimeStep ) //OP_MIN
{
  float local = 0.0f;
  local += maxEdgeEigenvalues0[0] * EdgeVolumes0[0];
  local += maxEdgeEigenvalues1[0] * EdgeVolumes1[0];
  local += maxEdgeEigenvalues2[0] * EdgeVolumes2[0];
  zeroInit[0] = 0.0f;
  zeroInit[1] = 0.0f;
  zeroInit[2] = 0.0f;
  zeroInit[3] = 0.0f;

  *minTimeStep = MIN(*minTimeStep, 2.0f * cellVolumes[0] / local);
}
