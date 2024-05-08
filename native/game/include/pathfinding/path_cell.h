#ifndef game_path_cell_h
#define game_path_cell_h

namespace d954masGame {
struct PathCell{
	bool blocked = false;
	int x,z,id;
	inline PathCell(){};
	inline PathCell(int x, int z, int id):x(x),z(z),id(id){};
	inline PathCell(int x, int z, int id, bool blocked):x(x),z(z),id(id),blocked(blocked){};
};
}

#endif
