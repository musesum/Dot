#ifndef IncludeFaceDefsH
#define IncludeFaceDefsH

//o//#define FaceMax   6
//o//#define FaceMax2 12

#define FaceMax  1
#define FaceMax2 2 

typedef enum
	{
	EdgeNwNe,
	EdgeNeSe,
	EdgeSeSw,
	EdgeSwNw,
	EdgeNwSw,
	EdgeSwSe,
	EdgeSeNe,
	EdgeNeNw,
	}
	Edges;

typedef enum
	{
	CubeFront=0,
	CubeBack,
	CubeRight,
	CubeLeft,
	CubeTop,
	CubeBottom,
	CubeFaceMax	// always last
	}
	CubeFaceName;

typedef enum 
	{
	FaceNil=0,		// inititialized to nothing
	
	FacePlane,		// 2D surface

	Cube1All,		// 1 surface mapped to all faces of a cube

	Cube1FrontQ,		// 1 surface, Front copied to Right,Back,Left, 
					// Front Northern 90 degree quadrant mapped  
					// as 4 quadrants of top surface with 
					// Front Southern 90 degree quadrand mapped 
					// as 4 quadrants of bottom	surface
								
	Cube1MirrorQ,	// 1 surface, Front is mirrored to Right & left with
					// front still copied to back surface with
					// northern quadrants of front,right,back,left
					// mapped to quadrants of top surface with
					// southern quadrants mapped to bottom surface

	Cube3FrightTB,	// 3 surfaces, Front+Right treated as one contiquous
					// surface that is mirrored to Back+Left with
					// top and bottom sufaces independently calced

	Cube3MirrorTB,	// 3 surfaces, Front mirrored to Right & left, copied 
					// to back with top and bottom calced independently
					
	Cube3Unique,	// 3 surfaces, Front+Right+Back+Left as one contiguous
					// surface with top and bottom calced independently
	
	Cube34Split,	// Source copied 3 times and split into 4 dest surface,,
					// which works well for mapping 1.333.aspect ratio 2d to 
					// left,front,right,back 3d cube, only problem left is to
					// rescale into 2^N texture map size -- so, 320 by 240 must 
					// be rescaled to 1024/4 by 256, not 960/4 by 240, so this
					// one has yet to be implemented

	Cube6Unique,	// 6 surface calced separately by univ, not yet implemented
	}
	FaceMapType;


#endif
