#import "FaceMap.h"

FaceMap::FaceMap(FaceMapType initMap)
:    faceMapType(initMap),
oldFaceMapType(FaceNil) {
	
	changed = false;
	newTexture = false;
}
void FaceMap::bindTr3(Tr3*root_) {

    root = root_;
    Tr3* screen = root->bind("screen");
    
    Tr3* face   = screen->bind("face");
	rendertex	= face->bind("rendertex");
	automipmap	= face->bind("automipmap");
	reflection	= face->bind("reflection");	
    
	foreground	= face->bind("foreground");
	background	= face->bind("background");
	wireframe	= face->bind("wireframe");
	showtexture = face->bind("texture");
    
	setForeground	= face->bind("set.foreground");
	setBackground	= face->bind("set.background");
	setWireframe	= face->bind("set.wireframe");
	setShowtexture	= face->bind("set.texture");
    
}
void FaceMap::init(Tr3*root_) {

    root = root_;
    bindTr3(root);
    
	switch (faceMapType)  {
            
        case Cube34Split:  // missed this one so drip through to nil
        case FaceNil:       setSurf(0,0);  setTileMap(0,0,0,0,0,0); split=1; mirror=false; quads=0; break;
        case FacePlane:		setSurf(1,1);  setTileMap(0,0,0,0,0,0); split=1; mirror=false; quads=0; break;
        case Cube1All:		setSurf(1,1);  setTileMap(0,0,0,0,0,0); split=1; mirror=false; quads=0; break;
        case Cube1FrontQ:   setSurf(1,3);  setTileMap(0,0,0,0,2,1); split=1; mirror=false; quads=1; break;
        case Cube1MirrorQ:	setSurf(1,4);  setTileMap(0,0,1,1,3,2); split=1; mirror=true;  quads=2; break;
        case Cube3FrightTB:	setSurf(3,4);  setTileMap(0,0,1,1,3,2); split=2; mirror=false; quads=0; break;
        case Cube3MirrorTB:	setSurf(3,4);  setTileMap(0,0,1,1,3,2); split=1; mirror=true;  quads=0; break;
        case Cube3Unique:   setSurf(3,6);  setTileMap(0,1,3,5,4,2); split=4; mirror=false; quads=0; break;
        case Cube6Unique:   setSurf(6,6);  setTileMap(0,1,2,3,4,5); split=1; mirror=false; quads=0; break;

    }
}
void FaceMap::go() {

	if (*setForeground) {
	 	setForeground->sneak((float)0);
		foreground->incrementNow();
    }
	if (*setBackground) {
		setBackground->sneak((float)0);
		background->incrementNow();
    }
	if (*setWireframe) {
		setWireframe->sneak((float)0);
		wireframe->incrementNow();
    }
	if (*setShowtexture) {
		setShowtexture->sneak((float)0);
		showtexture->incrementNow();
    }
}
void FaceMap::set(FaceMapType newMap) {

	faceMapType = newMap;
	init(root);
}
void FaceMap::setTileMap(int a, int b, int c, int d, int e, int f) {

    // tileMap is used to map tiling surfaces to cube surfaces
	tileMap[CubeFront]  = a; 
	tileMap[CubeBack]   = b; 
	tileMap[CubeRight]  = c; 
	tileMap[CubeLeft]   = d; 
	tileMap[CubeTop]    = e; 
	tileMap[CubeBottom] = f; 
}
void FaceMap::setSurf(int a, int b) {

	univSurfs = a; // number of surfaces used by universe
	tileSurfs = b; // number of surfaces used by tile
}
