#ifndef physics_obj_h
#define physics_obj_h

#include <dmsdk/sdk.h>
#include <dmsdk/dlib/message.h>

#include "objects/base_userdata.h"

using namespace dmMessage;


namespace d954masGame {

class PhysicsObject  : public BaseUserData{
    public:
    URL rootUrl;
    URL collisionUrl;
    dmGameObject::HInstance rootInstance;
    dmGameObject::HInstance collisionInstance;
    dmVMath::Vector3* position;
    dmVMath::Vector3* velocity;
    bool updatePosition = true;

    PhysicsObject(URL* root, dmGameObject::HInstance rootInstance, URL* collision,dmGameObject::HInstance collisionInstance,dmVMath::Vector3* position,dmVMath::Vector3* velocity);
    virtual ~PhysicsObject();
};

int PhysicsObjectDestroy(lua_State *L);
int PhysicsObjectCreate(lua_State *L);
int PhysicsObjectSetUpdatePosition(lua_State *L);

int PhysicsObjectsUpdateVariables(lua_State *L);
int PhysicsObjectsUpdateLinearVelocity(lua_State *L);


}
#endif