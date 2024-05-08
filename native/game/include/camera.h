#ifndef camera_h
#define camera_h

#include <dmsdk/sdk.h>

namespace d954Camera {

struct Camera {
    dmVMath::Vector3 viewPosition;
    dmVMath::Vector3 viewFront, viewUp, viewRight;
    dmVMath::Quat viewRotation;
    int screenW, screenH;
    float fov, zNear, zFar, aspect;
};

const Camera getCamera();
void reset();
void setScreenSize(int w, int h);
void setViewPosition(dmVMath::Vector3 position);
void setViewRotation(dmVMath::Quat rotation);
void getCameraView(dmVMath::Matrix4* matrix);
void getCameraPerspective(dmVMath::Matrix4* matrix);
void screenToWorldRay(int x, int y, dmVMath::Vector3* pStart, dmVMath::Vector3* pEnd);
void setZFar(float far);
void setFov(float fov);
float getFov();
float getFar();
float getNear();
}  // namespace d954Camera

#endif