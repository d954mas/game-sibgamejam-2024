#include "objects/distance_object.h"
#include "utils.h"
#include <math.h>
#include <algorithm>

#define META_NAME "Game::DistanceObjectClass"
#define USERDATA_TYPE "DistanceObject"

namespace dmScript {
    dmMessage::URL* CheckURL(lua_State* L, int index);
}


namespace d954masGame {

dmArray<DistanceObject*> list;

DistanceObject::DistanceObject(int r, dmVMath::Vector3* position, dmVMath::Vector3* distance,
    dmVMath::Vector3* distanceNormalized):  BaseUserData(USERDATA_TYPE,META_NAME){
    this->obj = this;
    this->entity_ref = r;
    this->position = position;
    this->distance = distance;
    this->distanceNormalized = distanceNormalized;
    if(list.Full()){
        list.OffsetCapacity(10);
    }
    list.Push(this);
}

DistanceObject::~DistanceObject() {

}

DistanceObject* DistanceObject_get_userdata_safe(lua_State *L, int index) {
    DistanceObject *lua_obj = (DistanceObject*) BaseUserData_get_userdata(L, index, USERDATA_TYPE);
    return lua_obj;
}


int DistanceObjectDestroy(lua_State *L) {
    check_arg_count(L, 1);
    DistanceObject *obj = DistanceObject_get_userdata_safe(L, 1);
    for(int i = 0; i < list.Size(); i++){
         if(list[i] == obj){
            list.EraseSwap(i);
            break;
         }
    }
    luaL_unref(L, LUA_REGISTRYINDEX, obj->entity_ref);
    obj->Destroy(L);
    delete obj;
    return 0;
}

int DistanceObjectCreate(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 1);
    check_arg_count(L, 4);

    if (!lua_istable(L, 1)){
        return DM_LUA_ERROR("need entity table");
    }
    lua_pushvalue(L, 1);
    int r = luaL_ref(L, LUA_REGISTRYINDEX);
    //lua_pop(L,1);
    Vectormath::Aos::Vector3 *position = dmScript::CheckVector3(L, 2);
    Vectormath::Aos::Vector3 *distance = dmScript::CheckVector3(L, 3);
    Vectormath::Aos::Vector3 *distanceNormalized = dmScript::CheckVector3(L, 4);

    DistanceObject* obj = new DistanceObject(r,position,distance,distanceNormalized);
    obj->Push(L);
    return 1;
}

int DistanceObjectsUpdate(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 1);
    dmVMath::Vector3* position = dmScript::CheckVector3(L, 1);

    for(int i=0;i<list.Size();i++){
        DistanceObject* obj = list[i];
        *obj->distance = *position - *obj->position;
        obj->distance->setY(0);
        *obj->distanceNormalized = Vectormath::Aos::normalize(*obj->distance);
        float distanceF = Vectormath::Aos::length(*obj->distance);
        lua_rawgeti(L, LUA_REGISTRYINDEX, obj->entity_ref);
        lua_pushnumber(L, distanceF);
        lua_setfield(L, -2, "distance_to_player");
        lua_pop(L,1);
    }
    return 0;
}



}


