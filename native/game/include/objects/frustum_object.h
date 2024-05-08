#ifndef frustum_obj_h
#define frustum_obj_h

#include <dmsdk/sdk.h>
#include <dmsdk/dlib/message.h>

#include "objects/base_userdata.h"

using namespace dmMessage;


namespace d954masGame {

class FrustumObject  : public BaseUserData{
private:
    dmArray<URL> urls;
public:
    dmVMath::Vector3 position;
    dmVMath::Vector3 size;
    dmVMath::Vector3 minp;
    dmVMath::Vector3 maxp;
    float maxDistance = -1;
    bool visible = false;

    FrustumObject();
    virtual ~FrustumObject();
    void setPosition(dmVMath::Vector3 position);
    void setSize(dmVMath::Vector3 size);
    void setVisible(lua_State *L,bool visible);
    void addUrl(lua_State *L,URL url);
    void removeUrl(lua_State *L,URL url);
};

void FrustumObjectInitMetaTable(lua_State *L);
FrustumObject* FrustumObject_get_userdata_safe(lua_State *L, int index);

}
#endif