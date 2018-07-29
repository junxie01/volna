inline void limiter(float *q,
  const float *value, const float *gradient,
  const float *edgecenter1, const float *edgecenter2,
  const float *edgecenter3, const float *cellcenter)
{

  float facevalue[3], dx[3], dy[3], y;
  int i, j;
  float edgealpha[3];

  dx[0] = (edgecenter1[0] - cellcenter[0]);
  dy[0] = (edgecenter1[1] - cellcenter[1]);
  dx[1] = (edgecenter2[0] - cellcenter[0]);
  dy[1] = (edgecenter2[1] - cellcenter[1]);
  dx[2] = (edgecenter3[0] - cellcenter[0]);
  dy[2] = (edgecenter3[1] - cellcenter[1]);
  // If the cell is not on the wet/dry boundary
  if((value[0] > EPS) && (q[0]> EPS)){
  // The limiter is calculated for all physical variables using the
  // Venkatakrishnan formula.
  // q[0] - Hmin , q[1] - Hmax , q[8] - Hlim
  // q[2] - Umin , q[3] - Umax , q[9] - Ulim
  // q[4] - Vmin , q[5] - Vmax , q[10] - Vlim
  // q[6] - Zmin , q[7] - Zmax , q[11] - Zlim
    for(j=0;j<4;j++){
      for(i =0 ; i<3; i++){
        facevalue[i] = value[j] + ((gradient[2*j]*dx[i]) + (gradient[2*j + 1]*dy[i]));
        if(facevalue[i] > value[j]) {
          y = (q[2*j + 1] - value[j]) / (facevalue[i] - value[j]);
          edgealpha[i] = (y*y + 2.0f*y) / (y*y + y + 2.0f);
        } else if (facevalue[i] < value[j]){
          y = (q[2*j] - value[j]) / (facevalue[i] - value[j]);
          edgealpha[i] = (y*y + 2.0f*y) / (y*y + y + 2.0f);
        } else{
          edgealpha[i] = 1.0f;
        }
      }
      q[j+8] = edgealpha[0] < edgealpha[1] ? q[j+8] : edgealpha[1];
      q[j+8] = q[j+8] < edgealpha[2] ? q[j+8]: edgealpha[2];
      q[j+8] = q[j+8] < 1.0f ? q[j+8] : 1.0f;
      q[j+8] = q[j+8] > 0.0f ? q[j+8] : 0.0f;
    }
  } else {
    q[8] = 0.0f;
    q[9] = 0.0f;
    q[10] = 0.0f;
    q[11] = 0.0f;
  }
}
