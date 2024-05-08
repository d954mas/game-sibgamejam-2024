#include "camera.h"

#define M_PI 3.14159265358979323846
#define DEG_TO_RAD 3.14159265358979323846 / 180.0

static const dmVMath::Vector3 FORWARD = dmVMath::Vector3(0, 0, -1);
static const dmVMath::Vector3 RIGHT = dmVMath::Vector3(1, 0, 0);
static const dmVMath::Vector3 UP = dmVMath::Vector3(0, 1, 0);

namespace d954Camera {

Camera mainCamera;

const Camera getCamera() { return mainCamera; }

void reset() {
    mainCamera.aspect = 16.0 / 9.0;  // w/h
    mainCamera.fov = 60 * DEG_TO_RAD;
    mainCamera.zNear = 0.1;
    mainCamera.zFar = 500;
    mainCamera.viewPosition = dmVMath::Vector3(0, 0, 0);
    setViewRotation(Vectormath::Aos::Quat::rotationZ(0));
}

void setScreenSize(int w, int h) {
    mainCamera.aspect = ((float)w) / h;
    mainCamera.screenW = w;
    mainCamera.screenH = h;
}

void setViewPosition(dmVMath::Vector3 position) {
    mainCamera.viewPosition = position;
}

void setZFar(float zFar){
    mainCamera.zFar = zFar;
}

void setFov(float fov){
    mainCamera.fov = fov;
}

float getFov(){
    return mainCamera.fov;
}

float getFar(){
    return mainCamera.zFar;
}

float getNear(){
    return mainCamera.zNear;
}


void setViewRotation(dmVMath::Quat rotation) {
    mainCamera.viewRotation = rotation;
    mainCamera.viewFront = Vectormath::Aos::rotate(rotation, FORWARD);
    mainCamera.viewRight = Vectormath::Aos::rotate(rotation, RIGHT);
    mainCamera.viewUp = Vectormath::Aos::rotate(rotation, UP);
}

void getCameraView(dmVMath::Matrix4* matrix) {
    Vectormath::Aos::Point3 eye = Vectormath::Aos::Point3(mainCamera.viewPosition);
    Vectormath::Aos::Point3 target = Vectormath::Aos::Point3(mainCamera.viewPosition + mainCamera.viewFront);
    *matrix = dmVMath::Matrix4::lookAt(eye, target, mainCamera.viewUp);
}

void getCameraPerspective(dmVMath::Matrix4* matrix) {
    *matrix = dmVMath::Matrix4::perspective(mainCamera.fov, mainCamera.aspect,
                                          mainCamera.zNear, mainCamera.zFar);
}

void screenToWorldRay(int x, int y, dmVMath::Vector3* pStart, dmVMath::Vector3* pEnd) {
    dmVMath::Matrix4 proj;
    dmVMath::Matrix4 view;
    getCameraView(&view);
    getCameraPerspective(&proj);
    dmVMath::Matrix4 m=  Vectormath::Aos::inverse(proj* view);
    // Remap coordinates to range -1 to 1
    float x1 = (x - mainCamera.screenW * 0.5) / mainCamera.screenW * 2.0;
    float y1 = (y - mainCamera.screenH * 0.5) / mainCamera.screenH * 2.0;

    dmVMath::Vector4 np = m * dmVMath::Vector4(x1,y1,-1,1);
    dmVMath::Vector4 fp = m * dmVMath::Vector4(x1,y1,1,1);

    np *= (1/np.getW());
    fp *= (1/fp.getW());

    pStart->setX(np.getX());
    pStart->setY(np.getY());
    pStart->setZ(np.getZ());

    pEnd->setX(fp.getX());
    pEnd->setY(fp.getY());
    pEnd->setZ(fp.getZ());
}

}  // namespace d954Camera