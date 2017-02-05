
typedef enum {
	Box,
	P1,	P2,
	Pm,	Pmm,
	Pg,	Pgg, Pmg,
	Cm,	Cmm,
	P4,	P4g, P4m,
	P3,	P31m,P3m1,
	P6,	P6m,
}  OldTileType;

typedef enum {
	TileUndef=-1,
	TileNone,
	TileHoriz,
	TileVert,
	TileBoth,
	TileMax
} TileType;