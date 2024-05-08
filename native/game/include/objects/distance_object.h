#ifndef distance_obj_h
#define distance_obj_h

#include <dmsdk/sdk.h>
#include <dmsdk/dlib/message.h>

#include "objects/base_userdata.h"

using namespace dmMessage;


namespace d954masGame {

class DistanceObject  : public BaseUserData{
    public:
    dmVMath::Vector3* position;
    dmVMath::Vector3* distance;
    dmVMath::Vector3* distanceNormalized;
    int entity_ref = LUA_REFNIL;

    DistanceObject(int r, dmVMath::Vector3* position, dmVMath::Vector3* distance, dmVMath::Vector3* distanceNormalized);
    virtual ~DistanceObject();
};

int DistanceObjectDestroy(lua_State *L);
int DistanceObjectCreate(lua_State *L);

int DistanceObjectsUpdate(lua_State *L);


}
#endif