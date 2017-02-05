
#import "Tr3.h"
#import "../pixel/Buf.h"
#import "FaceDefs.h"

#ifndef byte
#define byte unsigned char
#endif

struct FaceMap {
    
    Tr3* root;
    Tr3* rendertex;     // render to texture using pbuffer
    Tr3* automipmap;    // automatically generate mipmaps
    Tr3* reflection;    // texture is a reflection
    
    Tr3* foreground;    // show forground
    Tr3* background;    // show background
    Tr3* wireframe;
    Tr3* showtexture;
    
    Tr3* setForeground;	// show forground
    Tr3* setBackground;	// show background
    Tr3* setWireframe;
    Tr3* setShowtexture;
    
    FaceMapType faceMapType;
    FaceMapType oldFaceMapType;
    
    bool changed;    // 
    bool newTexture; // new Texture, reset by applyRen (bad design!)
    
    int univSurfs;	// number of universe surfaces
    int tileSurfs;	// number of tiling surfaces
    int tileMap[6]; // map tile surfaces to front,right,back,left,top,bottom, in that order
    int split;		// surface split into how many faces?
    
    int quads;		// tile top & bottom surfaces with 4 triangles 
                    // snipped 1 each from the side faces
    
    bool mirror;	// mirror front face to right and left faces?
    
    FaceMap	(FaceMapType initMap=FacePlane);
    
    void bindTr3(Tr3*root);
    void init(Tr3*root);
    void go();
    void set		(FaceMapType newMap);
    void setTileMap (int a,  int b,  int c,  int d,  int e,  int f);
    void setUnivTile(int a=0,int b=0,int c=0,int d=0,int e=0,int f=0);
    void setSurf	(int,int);
    
};
