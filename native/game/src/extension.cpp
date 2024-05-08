#define EXTENSION_NAME Game
#define LIB_NAME "Game"
#define MODULE_NAME "game"

#include <dmsdk/sdk.h>

#include "camera.h"
#include "utils.h"
#include "frustum_cull.h"
#include "pathfinding/map.h"
#include "world.h"
#include "objects/frustum_object.h"
#include "objects/distance_object.h"
#include "objects/physics_object.h"

#include "physics_defold.h"

static const char PHYSICS_CONTEXT_NAME[] = "__PhysicsContext";
static const uint32_t PHYSICS_CONTEXT_HASH = dmHashBuffer32(PHYSICS_CONTEXT_NAME,strlen(PHYSICS_CONTEXT_NAME));
static const dmhash_t HASH_POSITION = dmHashString64("position");
static char* COLLISION_OBJECT_EXT = "collisionobjectc";

using namespace d954masGame;

namespace dmGameObject {
    void GetComponentUserDataFromLua(lua_State* L, int index, HCollection collection, const char* component_ext, uintptr_t* out_user_data, dmMessage::URL* out_url, void** world);
    PropertyResult GetProperty(HInstance instance, dmhash_t component_id, dmhash_t property_id, PropertyOptions options, PropertyDesc& out_value);
    void* GetWorld(HCollection collection, uint32_t component_type_index);
}

namespace dmScript {
    dmMessage::URL* CheckURL(lua_State* L, int index);
    bool GetURL(lua_State* L, dmMessage::URL& out_url);
    bool GetURL(lua_State* L, dmMessage::URL* out_url);
    void GetGlobal(lua_State*L, uint32_t name_hash);
}


namespace dmGameSystem{
    struct PhysicsScriptContext
    {
       dmMessage::HSocket m_Socket;
       uint32_t m_ComponentIndex;
    };
     uint16_t CompCollisionGetGroupBitIndex(void* world, uint64_t group_hash);
      void RayCast(void* world, const dmPhysics::RayCastRequest& request, dmArray<dmPhysics::RayCastResponse>& results);
}

namespace d954masGame {
    extern World world;
}

//region camera

static int SetScreenSizeLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 2);
    d954Camera::setScreenSize(luaL_checknumber(L, 1), luaL_checknumber(L, 2));
    return 0;
}

static int CameraSetZFarLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 1);
    d954Camera::setZFar(luaL_checknumber(L, 1));
    return 0;
}

static int CameraSetFovLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 1);
    d954Camera::setFov(luaL_checknumber(L, 1));
    return 0;
}

static int CameraSetViewPositionLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 1);
    d954Camera::setViewPosition(*dmScript::CheckVector3(L, 1));
    return 0;
}

static int CameraSetViewRotationLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 1);
    d954Camera::setViewRotation(*dmScript::CheckQuat(L, 1));
    return 0;
}

static int CameraGetViewLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 1);
    d954Camera::getCameraView(dmScript::CheckMatrix4(L, 1));
    return 0;
}

static int CameraGetFarLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 1);
    check_arg_count(L, 0);
    lua_pushnumber(L,d954Camera::getFar());
    return 1;
}

static int CameraGetFovLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 1);
    check_arg_count(L, 0);
    lua_pushnumber(L,d954Camera::getFov());
    return 1;
}

static int CameraGetNearLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 1);
    check_arg_count(L, 0);
    lua_pushnumber(L,d954Camera::getNear());
    return 1;
}


static int CameraGetPerspectiveLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 1);
    d954Camera::getCameraPerspective(dmScript::CheckMatrix4(L, 1));
    return 0;
}

static int CameraScreenToWorldRayLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 6);
    check_arg_count(L, 2);
    int x = luaL_checknumber(L,1);
    int y = luaL_checknumber(L,2);
    dmVMath::Vector3 pStart;
    dmVMath::Vector3 pEnd;
    d954Camera::screenToWorldRay(x,y,&pStart,&pEnd);
    lua_pushnumber(L,pStart.getX());
    lua_pushnumber(L,pStart.getY());
    lua_pushnumber(L,pStart.getZ());

    lua_pushnumber(L,pEnd.getX());
    lua_pushnumber(L,pEnd.getY());
    lua_pushnumber(L,pEnd.getZ());
    return 6;
}

//endregion

//region frustum
namespace d954masGame {
    extern dmArray<FrustumObject*> frustum_list;
}

static Frustum g_Frustum;

static int Frustum_Set(lua_State* L){
    dmVMath::Matrix4* m = dmScript::CheckMatrix4(L, 1);
    g_Frustum           = Frustum(*m);
    return 0;
}

static int Frustum_Is_Box_Visible(lua_State* L){
    dmVMath::Vector3* v1 = dmScript::CheckVector3(L, 1);
    dmVMath::Vector3* v2 = dmScript::CheckVector3(L, 2);

    const bool visible = g_Frustum.IsBoxVisible(*v1, *v2);

    lua_pushboolean(L, visible);
    return 1;
}

static int FrustumObjectCreateLua(lua_State *L) {
	check_arg_count(L, 0);
    d954masGame::FrustumObject* obj = new d954masGame::FrustumObject();
    obj->Push(L);
	return 1;
}

static int FrustumObjectsListUpdateLua(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 1);
    Vectormath::Aos::Vector3 *camera_pos = dmScript::CheckVector3(L, 1);
    for(int i=0;i<d954masGame::frustum_list.Size();i++){
        d954masGame::FrustumObject* obj = d954masGame::frustum_list[i];
        bool visible = true;
        if(obj->maxDistance !=-1){
            Vectormath::Aos::Vector3 distv = *camera_pos-obj->position;
            visible = Vectormath::Aos::length(distv)<=obj->maxDistance;
        }

        if(visible){
            visible = g_Frustum.IsBoxVisible(obj->minp, obj->maxp);
        }
        obj->setVisible(L,visible);
    }
	return 0;
}
//endregion

//region physics
static int PhysicsCountMask(lua_State *L){
    DM_LUA_STACK_CHECK(L, 1);
    check_arg_count(L, 1);
    uint32_t mask = 0;
    luaL_checktype(L, 1, LUA_TTABLE);


    dmScript::GetGlobal(L, PHYSICS_CONTEXT_HASH);
    dmGameSystem::PhysicsScriptContext* context = (dmGameSystem::PhysicsScriptContext*)lua_touserdata(L, -1);
    lua_pop(L, 1);

    dmGameObject::HInstance sender_instance = dmScript::CheckGOInstance(L);
    dmGameObject::HCollection collection = dmGameObject::GetCollection(sender_instance);
    void* world = dmGameObject::GetWorld(collection, context->m_ComponentIndex);
    if (world == 0x0)
    {
        return DM_LUA_ERROR("Physics world doesn't exist. Make sure you have at least one physics component in collection.");
    }

    lua_pushnil(L);
    while (lua_next(L, 1) != 0)
    {
        mask |= dmGameSystem::CompCollisionGetGroupBitIndex(world, dmScript::CheckHash(L, -1));
        lua_pop(L, 1);
    }
    lua_pushnumber(L,mask);
    return 1;
}

int Physics_RayCastSingleExist(lua_State* L){
    DM_LUA_STACK_CHECK(L, 1);

    dmMessage::URL sender;
    if (!dmScript::GetURL(L, &sender)) {
        return luaL_error(L, "could not find a requesting instance for physics.raycast");
    }

    dmScript::GetGlobal(L, PHYSICS_CONTEXT_HASH);
    dmGameSystem::PhysicsScriptContext* context = (dmGameSystem::PhysicsScriptContext*)lua_touserdata(L, -1);
    lua_pop(L, 1);

    dmGameObject::HInstance sender_instance = dmScript::CheckGOInstance(L);
    dmGameObject::HCollection collection = dmGameObject::GetCollection(sender_instance);
    void* world = dmGameObject::GetWorld(collection, context->m_ComponentIndex);
    if (world == 0x0)
    {
        return DM_LUA_ERROR("Physics world doesn't exist. Make sure you have at least one physics component in collection.");
    }

    dmVMath::Point3 from( *dmScript::CheckVector3(L, 1) );
    dmVMath::Point3 to( *dmScript::CheckVector3(L, 2) );

    uint32_t mask = luaL_checknumber(L,3);


    dmArray<dmPhysics::RayCastResponse> hits;
    hits.SetCapacity(32);

    dmPhysics::RayCastRequest request;
    request.m_From = from;
    request.m_To = to;
    request.m_Mask = mask;
    request.m_ReturnAllResults = 0;

    dmGameSystem::RayCast(world, request, hits);
    lua_pushboolean(L,!hits.Empty());
    return 1;
}

int Physics_RayCastSingle(lua_State* L){
  //  DM_LUA_STACK_CHECK(L, 4);

    dmMessage::URL sender;
    if (!dmScript::GetURL(L, &sender)) {
        return luaL_error(L, "could not find a requesting instance for physics.raycast");
    }

    dmScript::GetGlobal(L, PHYSICS_CONTEXT_HASH);
    dmGameSystem::PhysicsScriptContext* context = (dmGameSystem::PhysicsScriptContext*)lua_touserdata(L, -1);
    lua_pop(L, 1);

    dmGameObject::HInstance sender_instance = dmScript::CheckGOInstance(L);
    dmGameObject::HCollection collection = dmGameObject::GetCollection(sender_instance);
    void* world = dmGameObject::GetWorld(collection, context->m_ComponentIndex);
    if (world == 0x0)
    {
        return luaL_error(L,"Physics world doesn't exist. Make sure you have at least one physics component in collection.");
    }

    dmVMath::Point3 from( *dmScript::CheckVector3(L, 1) );
    dmVMath::Point3 to( *dmScript::CheckVector3(L, 2) );

    uint32_t mask = luaL_checknumber(L,3);

    dmArray<dmPhysics::RayCastResponse> hits;
    hits.SetCapacity(32);

    dmPhysics::RayCastRequest request;
    request.m_From = from;
    request.m_To = to;
    request.m_Mask = mask;
    request.m_ReturnAllResults = 0;

    dmGameSystem::RayCast(world, request, hits);
    lua_pushboolean(L,!hits.Empty());
    if(hits.Empty()){
        return 1;
    }else{
        dmPhysics::RayCastResponse& resp1 = hits[0];
        lua_pushnumber(L,resp1.m_Position.getX());
        lua_pushnumber(L,resp1.m_Position.getY());
        lua_pushnumber(L,resp1.m_Position.getZ());

        lua_pushnumber(L,resp1.m_Normal.getX());
        lua_pushnumber(L,resp1.m_Normal.getY());
        lua_pushnumber(L,resp1.m_Normal.getZ());
        return 7;
    }
}
//endregion

//region Pathfinding
static int PathfindingIsBlockedData(lua_State *L) {
	check_arg_count(L, 2);
    PathCell* cell = world.map.getCell(lua_tonumber(L,1),lua_tonumber(L,2));
    if(cell == NULL){
        lua_pushboolean(L,true);
    }else{
          lua_pushboolean(L,cell->blocked);
    }
	return 1;
}

static int PathfindingSetBlockedData(lua_State *L) {
	check_arg_count(L, 3);
    PathCell* cell = world.map.getCell(lua_tonumber(L,1),lua_tonumber(L,2));
    cell->blocked = lua_toboolean(L,3);
    world.map.Reset();
	return 0;
}

static int PathfindingFindPath(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 1);
	check_arg_count(L, 5);
	if (!lua_istable(L,1)){
	    return DM_LUA_ERROR("need table cells");
	}
    dmArray<PathCell> cells;
    cells.SetCapacity(16);
    int result = world.map.findPath(lua_tonumber(L,2),lua_tonumber(L,3),lua_tonumber(L,4),lua_tonumber(L,5),&cells);
    int cells_len = lua_objlen(L,1);

   lua_pushvalue(L,1);//move cells table on top

   //remove cell from cells table if it bigger than we need
   for(int i=cells.Size();i<cells_len;++i){
        lua_pushnil(L);
        lua_rawseti(L, -2, i+1);
   }

    for(int i=0;i<cells.Size();i++){
       PathCell cell = cells[i];
       if(i<cells_len){
            lua_rawgeti(L,-1,i+1);
            dmVMath::Vector3* v3 = dmScript::CheckVector3(L, -1);
            lua_pop(L,1);
            v3->setX(cell.x);
            v3->setY(0);
            v3->setZ(cell.z);
       }else{
            dmScript::PushVector3(L,dmVMath::Vector3(cell.x,0,cell.z));
            lua_rawseti(L, -2, i+1);
       }
   }
   lua_pop(L,1);

    lua_pushboolean(L,result == MicroPather::MicroPather::SOLVED);

	return 1;
}
//endregion

static int SmoothDumpV3(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
	check_arg_count(L, 7);

    dmVMath::Vector3 *currentV3 = dmScript::CheckVector3(L, 1);
    dmVMath::Vector3 current = *currentV3;
    dmVMath::Vector3 target = *dmScript::CheckVector3(L, 2);
    dmVMath::Vector3 *currentVelocity = dmScript::CheckVector3(L, 3);
    dmVMath::Vector3 velocity = *currentVelocity;

    float smoothTime = luaL_checknumber(L,4);
    float maxSpeed = luaL_checknumber(L,5);
    float maxDistance = luaL_checknumber(L,6);
    float dt = luaL_checknumber(L,7);


    smoothTime = fmax(0.0001, smoothTime);

    float num = (2.0 / smoothTime);
    float num2 = (num * dt);
    float d = (1.0 / (1.0 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2));



    dmVMath::Vector3 vector = (current - target);
    dmVMath::Vector3 vector2 = target;

    float maxLength = (maxSpeed * smoothTime);

    vector = Vectormath::Aos::length(vector) > maxLength ? (Vectormath::Aos::normalize(vector) * maxLength) : vector; // Clamp magnitude.
    dmVMath::Vector3 distance = (current - vector);

    dmVMath::Vector3 vector3 = ((velocity + num * vector) * dt);
    velocity = ((velocity - num * vector3) * d);

    dmVMath::Vector3 vector4 = (distance + (vector + vector3) * d);
    if(Vectormath::Aos::dot(vector2 - current,vector4 - vector2)>0){
        vector4 = vector2;
        velocity = ((vector4 - vector2) / dt);
    }

    *currentV3 = vector4;
    *currentVelocity = velocity;

    //check maxDistance
    vector = vector4-target;
    if(Vectormath::Aos::length(vector)>maxDistance){
        dmVMath::Vector3 dmove = Vectormath::Aos::normalize(vector) * maxDistance;
        *currentV3 =  target+dmove;
    }

	return 0;
}

 // Helper to get collisionobject component and world.
static int MeshSetAABB(lua_State *L) {
    DM_LUA_STACK_CHECK(L, 0);
    check_arg_count(L, 1);
    dmBuffer::HBuffer mesh = dmScript::CheckBufferUnpack(L, 1);
  //  dmBuffer::Result validate = dmBuffer::ValidateBuffer(mesh);
  //  if(validate!=dmBuffer::RESULT_OK ){
    //    luaL_error(L,"buffer invalid");
 //   }
//
    float* positions = 0x0;
    uint32_t components = 0;
    uint32_t stride = 0;
    uint32_t count = 0;
    dmBuffer::Result r = dmBuffer::GetStream(mesh, HASH_POSITION, (void**)&positions, &count, &components, &stride);


    if (r == dmBuffer::RESULT_OK) {
        //must have at least 1 point
        if(count>0){
            float aabb[6];
            //min
            aabb[0] = positions[0];
            aabb[1] = positions[1];
            aabb[2] = positions[2];
            //max
            aabb[3] = positions[0];
            aabb[4] = positions[1];
            aabb[5] = positions[2];
            positions += stride;
            for (int i = 1; i < count; ++i){
                float x = positions[0];
                float y = positions[1];
                float z = positions[2];
                if(x<aabb[0]) aabb[0] = x;
                if(y<aabb[1]) aabb[1] = y;
                if(z<aabb[2]) aabb[2] = z;

                if(x>aabb[3]) aabb[3] = x;
                if(y>aabb[4]) aabb[4] = y;
                if(z>aabb[5]) aabb[5] = z;
                positions += stride;
            }
           // dmLogInfo("AABB{%.3f %.3f %.3f %.3f %.3f %.3f}",aabb[0],aabb[1],aabb[2],aabb[3],aabb[4],aabb[5])
            dmBuffer::Result metaDataResult = dmBuffer::SetMetaData(mesh, dmHashString64("AABB"), &aabb, 6, dmBuffer::VALUE_TYPE_FLOAT32);
            if (metaDataResult != dmBuffer::RESULT_OK) {
                return DM_LUA_ERROR("dmBuffer can't set AABB metadata");
            }
        }
    } else {
        return DM_LUA_ERROR("dmBuffer can't get position.Error:%d",r);
    }
    return 0;
}


static int FillStreamFloats(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    dmBuffer::HBuffer buffer = dmScript::CheckBufferUnpack(L, 1);
    dmhash_t streamName = dmScript::CheckHashOrString(L,2);
    int componentsSize = lua_tonumber(L,3);
    if (!lua_istable(L, 4)) {
         return DM_LUA_ERROR("data not table");
    }

    float* values = 0x0;
    uint32_t sizeBuffer = 0;
    uint32_t components = 0;
    uint32_t stride = 0;
    dmBuffer::Result dataResult = dmBuffer::GetStream(buffer, streamName, (void**)&values, &sizeBuffer, &components, &stride);
    if (dataResult != dmBuffer::RESULT_OK) {
       return DM_LUA_ERROR("can't get stream");
    }

    if (components!=componentsSize){
         return DM_LUA_ERROR("stream have: %d components. Need %d", components, componentsSize);
    }

    int size = luaL_getn(L, 3);
    if (size/components>=sizeBuffer){
        return DM_LUA_ERROR("buffer not enought size");
    }

    for (int i=0; i<sizeBuffer; ++i) {
        for (int j=0;j<components;++j){
            lua_rawgeti(L, 4, i*components+j+1);
            values[j] = lua_tonumber(L,-1);
            lua_pop(L,1);
        }
        values += stride;
    }
    dmBuffer::UpdateContentVersion(buffer);
    return 0;
}

static int FillStreamUInt8(lua_State* L){
    DM_LUA_STACK_CHECK(L, 0);
    dmBuffer::HBuffer buffer = dmScript::CheckBufferUnpack(L, 1);
    dmhash_t streamName = dmScript::CheckHashOrString(L,2);
    int componentsSize = lua_tonumber(L,3);
    if (!lua_istable(L, 4)) {
         return DM_LUA_ERROR("data not table");
    }

    uint8_t* values = 0x0;
    uint32_t sizeBuffer = 0;
    uint32_t components = 0;
    uint32_t stride = 0;
    dmBuffer::Result dataResult = dmBuffer::GetStream(buffer, streamName, (void**)&values, &sizeBuffer, &components, &stride);
    if (dataResult != dmBuffer::RESULT_OK) {
       return DM_LUA_ERROR("can't get stream");
    }

    if (components!=componentsSize){
         return DM_LUA_ERROR("stream have: %d components. Need %d", components, componentsSize);
    }

    int size = luaL_getn(L, 3);
    if (size/components>=sizeBuffer){
        return DM_LUA_ERROR("buffer not enought size");
    }

    for (int i=0; i<sizeBuffer; ++i) {
        for (int j=0;j<components;++j){
            lua_rawgeti(L, 4, i*components+j+1);
            values[j] = lua_tonumber(L,-1);
            lua_pop(L,1);
        }
        values += stride;
    }
    dmBuffer::UpdateContentVersion(buffer);
    return 0;
}

static int CreateAndFillWaterBufferLua(lua_State* L) {
    DM_LUA_STACK_CHECK(L, 1);

    // Reading parameters from Lua
    float w = (float)luaL_checknumber(L, 1);
    float h = (float)luaL_checknumber(L, 2);
    float rows = luaL_checkinteger(L, 3);
    float columns = luaL_checkinteger(L, 4);
    int vertices = 6 * rows * columns; // 6 vertices per cell

    // Defining the buffer structure
    const dmBuffer::StreamDeclaration streams_decl[] = {
        {dmHashString64("position"), dmBuffer::VALUE_TYPE_FLOAT32, 3},
        {dmHashString64("normal"), dmBuffer::VALUE_TYPE_FLOAT32, 3},
        {dmHashString64("texcoord0"), dmBuffer::VALUE_TYPE_FLOAT32, 2},
    };
    dmBuffer::HBuffer buffer = 0x0;
    dmBuffer::Result r = dmBuffer::Create(vertices, streams_decl, 3, &buffer);

    if (r != dmBuffer::RESULT_OK) {
        return DM_LUA_ERROR("can't create buffer");
    }

    // Accessing the streams
    float* positions = 0x0;
    uint32_t stridePositions = 0;
    float* normals = 0x0;
    uint32_t strideNormals = 0;
    float* texcoord0 = 0x0;
    uint32_t strideTexcoord0 = 0;
    uint32_t stream_count;

    r = dmBuffer::GetStream(buffer, dmHashString64("position"), (void**)&positions, &stream_count, 0x0, &stridePositions);
    if (r != dmBuffer::RESULT_OK) {
        return DM_LUA_ERROR("failed to get position stream");
    }
    r = dmBuffer::GetStream(buffer, dmHashString64("normal"), (void**)&normals, &stream_count, 0x0, &strideNormals);
    if (r != dmBuffer::RESULT_OK) {
        return DM_LUA_ERROR("failed to get normal stream");
    }
    r = dmBuffer::GetStream(buffer, dmHashString64("texcoord0"), (void**)&texcoord0, &stream_count, 0x0, &strideTexcoord0);
    if (r != dmBuffer::RESULT_OK) {
        return DM_LUA_ERROR("failed to get texcoord stream");
    }

    // Filling the buffer
    int idx = 0;
    for (int row = 0; row < rows; ++row) {
        float z0 = (rows - row) * h / rows - h / 2;
        float z1 = (rows - (row + 1)) * h / rows - h / 2;
        float v0 = 1.0f - row /rows;
        float v1 = 1.0f - (row+1) /rows;
        for (int col = 0; col < columns; ++col) {
            float x0 = col * w / columns - w / 2;
            float x1 = (col + 1) * w / columns - w / 2;
            float u0 = col / columns;
            float u1 = (col+1) / columns;

           // dmLogInfo("id:%d x0:%.3f x1:%.3f z0:%.3f z1:%.3f u0:%.3f u1:%.3f v0:%.3f v1:%.3f",idx,x0,x1,z0,z1,u0,u1,v0,v1);

            // First triangle
            positions[idx * stridePositions] = x0;
            positions[idx * stridePositions + 1] = 0;
            positions[idx * stridePositions + 2] = z0;
            texcoord0[idx * strideTexcoord0] = u0;
            texcoord0[idx * strideTexcoord0 + 1] = v0;
            idx++;

            positions[idx * stridePositions] = x1;
            positions[idx * stridePositions + 1] = 0;
            positions[idx * stridePositions + 2] = z0;
            texcoord0[idx * strideTexcoord0] = u1;
            texcoord0[idx * strideTexcoord0 + 1] = v0;
            idx++;

            positions[idx * stridePositions] = x1;
            positions[idx * stridePositions + 1] = 0;
            positions[idx * stridePositions + 2] = z1;
            texcoord0[idx * strideTexcoord0] = u1;
            texcoord0[idx * strideTexcoord0 + 1] = v1;
            idx++;

            // Second triangle
            positions[idx * stridePositions] = x0;
            positions[idx * stridePositions + 1] = 0;
            positions[idx * stridePositions + 2] = z0;
            texcoord0[idx * strideTexcoord0] = u0;
            texcoord0[idx * strideTexcoord0 + 1] = v0;
            idx++;

            positions[idx * stridePositions] = x1;
            positions[idx * stridePositions + 1] = 0;
            positions[idx * stridePositions + 2] = z1;
            texcoord0[idx * strideTexcoord0] = u1;
            texcoord0[idx * strideTexcoord0 + 1] = v1;
            idx++;

            positions[idx * stridePositions] = x0;
            positions[idx * stridePositions + 1] = 0;
            positions[idx * stridePositions + 2] = z1;
            texcoord0[idx * strideTexcoord0] = u0;
            texcoord0[idx * strideTexcoord0 + 1] = v1;
            idx++;
        }
    }

    // Set normals for all vertices
    for (int i = 0; i < vertices; ++i) {
        normals[i * strideNormals] = 0;
        normals[i * strideNormals + 1] = 1;
        normals[i * strideNormals + 2] = 0;
    }

    // Push the filled buffer to Lua
    dmScript::LuaHBuffer luabuf(buffer, dmScript::OWNER_LUA);
    dmScript::PushBuffer(L, luabuf);
    return 1;
}





// Functions exposed to Lua
static const luaL_reg Module_methods[] = {
    {"set_screen_size", SetScreenSizeLua},
    {"camera_set_view_position", CameraSetViewPositionLua},
    {"camera_set_z_far", CameraSetZFarLua},
    {"camera_set_fov", CameraSetFovLua},
    {"camera_set_view_rotation", CameraSetViewRotationLua},
	{"camera_get_view", CameraGetViewLua},
	{"camera_get_perspective", CameraGetPerspectiveLua},
	{"camera_get_far", CameraGetFarLua},
	{"camera_get_near", CameraGetNearLua},
	{"camera_get_fov", CameraGetFovLua},
	{"camera_screen_to_world_ray", CameraScreenToWorldRayLua},

    { "frustum_set", Frustum_Set },
    { "frustum_is_box_visible", Frustum_Is_Box_Visible },
    { "frustum_object_create", FrustumObjectCreateLua },
    { "frustum_objects_list_update", FrustumObjectsListUpdateLua },

    { "physics_object_create", d954masGame::PhysicsObjectCreate},
    { "physics_object_destroy", d954masGame::PhysicsObjectDestroy},
    { "physics_object_set_update_position", d954masGame::PhysicsObjectSetUpdatePosition},
    { "physics_objects_update_variables", d954masGame::PhysicsObjectsUpdateVariables},
    { "physics_objects_update_linear_velocity", d954masGame::PhysicsObjectsUpdateLinearVelocity},

    { "distance_object_create", d954masGame::DistanceObjectCreate},
    { "distance_object_destroy", d954masGame::DistanceObjectDestroy},
    { "distance_objects_update", d954masGame::DistanceObjectsUpdate},


    { "physics_raycast_single_exist", Physics_RayCastSingleExist },
    { "physics_raycast_single", Physics_RayCastSingle},
    { "physics_count_mask", PhysicsCountMask},


    { "pathfinding_is_blocked", PathfindingIsBlockedData},
    { "pathfinding_set_blocked", PathfindingSetBlockedData},
    { "pathfinding_find_path", PathfindingFindPath},

    { "smooth_dump_v3", SmoothDumpV3},

    { "mesh_set_aabb", MeshSetAABB},

    {"fill_stream_floats",FillStreamFloats},
    {"fill_stream_uint8",FillStreamUInt8},
    {"create_and_fill_water_buffer",CreateAndFillWaterBufferLua},

    {0, 0}

};

static void LuaInit(lua_State *L) {
    int top = lua_gettop(L);
    luaL_register(L, MODULE_NAME, Module_methods);
    lua_pop(L, 1);
    d954masGame::FrustumObjectInitMetaTable(L);
    assert(top == lua_gettop(L));
}

static dmExtension::Result AppInitializeMyExtension(dmExtension::AppParams *params) { return dmExtension::RESULT_OK; }
static dmExtension::Result InitializeMyExtension(dmExtension::Params *params) {
    // Init Lua
    LuaInit(params->m_L);
    d954Camera::reset();

    printf("Registered %s Extension\n", MODULE_NAME);
    return dmExtension::RESULT_OK;
}

static dmExtension::Result AppFinalizeMyExtension(dmExtension::AppParams *params) { return dmExtension::RESULT_OK; }

static dmExtension::Result FinalizeMyExtension(dmExtension::Params *params) { return dmExtension::RESULT_OK; }

DM_DECLARE_EXTENSION(EXTENSION_NAME, LIB_NAME, AppInitializeMyExtension, AppFinalizeMyExtension, InitializeMyExtension, 0, 0, FinalizeMyExtension)