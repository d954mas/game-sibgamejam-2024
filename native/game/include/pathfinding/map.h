#ifndef game_map_h
#define game_map_h
#include <dmsdk/sdk.h>
#include "pathfinding/micropather.h"
#include "pathfinding/path_cell.h"
using namespace micropather;
namespace d954masGame {

class Map  : public Graph{
	private:
		MicroPather* pather;
	public:
		PathCell* cells=NULL;
		int maxId;
		int width,depth;
		Map();
		virtual ~Map();
        inline bool CoordsInside(int x, int z){
            return false;
        }
		inline int CoordsToId(int x, int z){
            if(CoordsInside(x,z)){
                return 1;
            }else{
                return -1;
            }
        }
		inline int CoordsToId(float fx,float fz){
		    return CoordsToId((int)floor(fx),(int)floor(fz));
		}
		inline void Reset(){
		    pather->Reset();
		}


		inline void IdToCoords(const int id,int *x, int *y){
		    *y = id / width;//+chunks->zMinVoxels;
		    *x = id % width;//+chunks->xMinVoxels;
		};
		inline bool Passable(int startX, int startY, int endX, int endY) {
            if (false){
                PathCell startCell = cells[CoordsToId(startX,startY)];
                if(startCell.blocked){return false;}
                PathCell cell = cells[CoordsToId(endX,endY)];
                if (cell.blocked){
                    return false;
                }else{
                   int dx = endX-startX;
                   int dy = endY-startY;
                     //check diagonals
                   if (dx!=0 && dy !=0){
                        int coord1 = CoordsToId(startX+dx,startY);
                        int coord2 = CoordsToId(startX,startY+dy);
                        if(coord1==-1 || coord2 == -1){return false;}
                        return !cells[coord1].blocked && !cells[coord2].blocked;
                   }else{
                        return true;
                   }
                }
            }
            return false;
        }

		int findPath(int, int, int, int, dmArray<PathCell>*);
		PathCell* getCell(float x, float z);
		virtual float LeastCostEstimate( void* stateStart, void* stateEnd );
		virtual void AdjacentCost( void* state, MP_VECTOR< micropather::StateCost > *neighbors );
		virtual void PrintStateInfo(void* state);
};

}

#endif