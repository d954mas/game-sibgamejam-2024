#include "objects/frustum_object.h"
#include "utils.h"
#include <math.h>
#include <algorithm>
#include <gameobject/gameobject_ddf.h> // dmGameObjectDDF enable/disable

#define META_NAME "Game::FrustumObjectClass"
#define USERDATA_TYPE "FrustumObject"

namespace dmScript {
    dmMessage::URL* CheckURL(lua_State* L, int index);
}


namespace d954masGame {

dmArray<FrustumObject*> frustum_list;

FrustumObject::FrustumObject():  BaseUserData(USERDATA_TYPE, META_NAME){
    this->obj = this;
    if(frustum_list.Full()){
        frustum_list.OffsetCapacity(10);
    }
    frustum_list.Push(this);
    this->urls.SetCapacity(4);
}

FrustumObject::~FrustumObject() {

}

void FrustumObject::setPosition(dmVMath::Vector3 position) {
    this->position = position;
    this->minp = this->position - this->size/2;
    this->maxp = this->position + this->size/2;
}

void FrustumObject::setSize(dmVMath::Vector3 size) {
    this->size = size;
    this->minp = this->position - this->size/2;
    this->maxp = this->position + this->size/2;
}

static inline void enableObj(lua_State *L,URL url){
    dmGameObject::HInstance instance = dmScript::CheckGOInstance(L);
    dmGameObjectDDF::Enable msg;
    dmMessage::Result result = dmMessage::PostDDF(&msg,0x0, &url,
        (uintptr_t) instance,0, 0);
    if(result!=dmMessage::RESULT_OK){
         dmLogError("can't enable object");
    }
}

static inline void disableObj(lua_State *L,URL url){
    dmGameObject::HInstance instance = dmScript::CheckGOInstance(L);
    dmGameObjectDDF::Disable msg;
    dmMessage::Result result = dmMessage::PostDDF(&msg,0x0, &url,
        (uintptr_t) instance,0, 0);
    if(result!=dmMessage::RESULT_OK){
        dmLogError("can't disable object");
    }
}

void FrustumObject::setVisible(lua_State *L,bool visible) {
    if(this->visible != visible){
        this->visible = visible;
        for(int i = 0; i < urls.Size(); i++){
             if(visible){
                enableObj(L,urls[i]);
             }else{
                disableObj(L,urls[i]);
             }
        }
    }

}

void FrustumObject::addUrl(lua_State *L,URL url) {
    if(this->urls.Full()){
        this->urls.OffsetCapacity(1);
    }
    this->urls.Push(url);
    if(visible){
        enableObj(L,url);
    }else{
        disableObj(L,url);
    }
}

void FrustumObject::removeUrl(lua_State *L,URL url) {
    for(int i = 0; i < urls.Size(); i++){
        URL url2 = urls[i];
        if(url.m_Socket == url2.m_Socket && url.m_Path == url2.m_Path && url.m_Fragment == url2.m_Fragment){
            urls.EraseSwap(i);
            return;
        }
    }
    dmLogError("url not existed");
}




FrustumObject* FrustumObject_get_userdata_safe(lua_State *L, int index) {
    FrustumObject *lua_obj = (FrustumObject*) BaseUserData_get_userdata(L, index, USERDATA_TYPE);
    return lua_obj;
}

static int SetPositionLua(lua_State *L) {
    check_arg_count(L, 2);
    FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
    dmVMath::Vector3* position = dmScript::CheckVector3(L, 2);
    obj->setPosition(*position);
    return 0;
}
static int SetSizeLua(lua_State *L) {
    check_arg_count(L, 2);
    FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
    dmVMath::Vector3* size = dmScript::CheckVector3(L, 2);
    obj->setSize(*size);
    return 0;
}
static int SetDistanceLua(lua_State *L) {
    check_arg_count(L, 2);
    FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
    obj->maxDistance = luaL_checknumber(L, 2);
    return 0;
}

static int GetPositionRawLua(lua_State *L) {
    check_arg_count(L, 1);
    FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
    lua_pushnumber(L, obj->position.getX());
    lua_pushnumber(L, obj->position.getY());
    lua_pushnumber(L, obj->position.getZ());
    return 3;
}
static int GetSizeRawLua(lua_State *L) {
   check_arg_count(L, 1);
   FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
   lua_pushnumber(L, obj->size.getX());
   lua_pushnumber(L, obj->size.getY());
   lua_pushnumber(L, obj->size.getZ());
    return 3;
}
static int IsVisibleLua(lua_State *L) {
   check_arg_count(L, 1);
   FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
   lua_pushboolean(L,obj->visible);
    return 1;
}

static int AddURLLua(lua_State *L) {
   check_arg_count(L, 2);
   FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
   URL *url = dmScript::CheckURL(L, 2);
   obj->addUrl(L,*url);
    return 0;
}

static int RemoveURLLua(lua_State *L) {
    check_arg_count(L, 2);
    FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
    URL *url = dmScript::CheckURL(L, 2);
    obj->removeUrl(L,*url);
    return 0;
}



static int Destroy(lua_State *L) {
    check_arg_count(L, 1);
    FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
    for(int i = 0; i < frustum_list.Size(); i++){
         if(frustum_list[i] == obj){
            frustum_list.EraseSwap(i);
            break;
         }
    }
    obj->Destroy(L);
    delete obj;
    return 0;
}


static int ToString(lua_State *L){
    check_arg_count(L, 1);
    FrustumObject *obj = FrustumObject_get_userdata_safe(L, 1);
    lua_pushfstring( L, "FrustumObject[%p]",(void *) obj);
	return 1;
}



void FrustumObjectInitMetaTable(lua_State *L){
    int top = lua_gettop(L);

    luaL_Reg functions[] = {
        {"Destroy",Destroy},
        {"SetSize",SetSizeLua},
        {"SetPosition",SetPositionLua},
        {"GetPositionRaw",GetPositionRawLua},
        {"GetSizeRaw",GetSizeRawLua},
        {"IsVisible",IsVisibleLua},
        {"AddURL",AddURLLua},
        {"RemoveURL",RemoveURLLua},
        {"SetDistance",SetDistanceLua},
        {"__tostring",ToString},
        { 0, 0 }
    };
    luaL_newmetatable(L, META_NAME);
    luaL_register (L, NULL,functions);
    lua_pushvalue(L, -1);
    lua_setfield(L, -1, "__index");
    lua_pop(L, 1);


    assert(top == lua_gettop(L));
}





}


