#include <dmsdk/sdk.h>
#include "pathfinding/micropather.h"
#include "pathfinding/map.h"
#include "pathfinding/path_cell.h"

namespace d954masGame {

Map::Map(){
	pather = new MicroPather( this, 2048,8, true );
}
Map::~Map() {
    delete pather;
    if(this->cells!=NULL){
        delete[] this->cells;
    }

}

//(int)((size_t)id) fixed loses precision error
//Return the least possible cost between 2 states.
float Map::LeastCostEstimate( void* stateStart, void* stateEnd ){
	PathCell start = cells[(int)((size_t)stateStart)];
    PathCell end = cells[(int)((size_t)stateEnd)];
	return  pow(end.x - start.x,2) + pow(end.z - start.z,2);
}

static const int dx[8] = { 1, 1, 0, -1, -1, -1,  0,  1 };
static const int dy[8] = { 0, 1, 1,  1,  0, -1, -1, -1 };
static const float cost[8] = { 1.0f, 1.41f, 1.0f, 1.41f, 1.0f, 1.41f, 1.0f, 1.41f };

void Map::AdjacentCost( void* state, MP_VECTOR< micropather::StateCost > *neighbors  ){
	PathCell cellData = cells[(int)((size_t)state)];
	if(cellData.blocked){return;}
    for( int i=0; i<8; ++i ) {
        int nx = cellData.x  + dx[i];
        int ny = cellData.z + dy[i];
		bool pass = Passable(cellData.x,cellData.z,nx,ny);
        if(pass){
            StateCost nodeCost = {(void*)CoordsToId(nx,ny), cost[i] };
            neighbors->push_back( nodeCost );
        }
    }
}

/**This function is only used in DEBUG mode - it dumps output to stdout. Since void* 
aren't really human readable, normally you print out some concise info (like "(1,2)") 
without an ending newline.*/
void Map::PrintStateInfo(void* state){printf("print info");}

int Map::findPath(int x, int y, int x2, int y2,  dmArray<PathCell>* resultPath){
	resultPath->SetSize(0);
	void* startState = (void*)(CoordsToId(x,y));
	void* endState = (void*)(CoordsToId(x2,y2));
	MP_VECTOR< void* > path;
	float totalCost = 0;
    if (startState == endState){
        resultPath->SetCapacity(fmax(resultPath->Capacity(),1));
        resultPath->Push(cells[(int)((size_t)startState)]);
        return micropather::MicroPather::SOLVED;
	}else{
        int result = pather->Solve( startState, endState, &path, &totalCost );
        resultPath->SetCapacity(fmax(resultPath->Capacity(),path.size()));
        for(int i=0;i<path.size();i++){
            resultPath->Push(cells[(long)path[i]]);
        }
        return result;
	}
//	pather->Reset();
}

PathCell* Map::getCell(float x, float z){
    int id = CoordsToId(x,z);
    if(id == -1){ return NULL;}
    return &cells[id];
}

}