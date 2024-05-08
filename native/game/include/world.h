#ifndef world_h
#define world_h

#include "pathfinding/map.h"


namespace d954masGame {

struct World {
    public:
    Map map;

    World();
    ~World();
};



} // namespace d954masGame

#endif