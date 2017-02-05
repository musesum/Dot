#import "main.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


typedef enum {
    kDrawPixShow,
    kDrawPixWrite,
    kDrawPixThru,
    kDrawScreen2, //TODO: kludge
} DrawPixType;

@interface ShaderVertex : NSObject {

    CGSize _margin;
	CGSize _screenSize;    // size of screen to display quad
	CGSize _videoDimensions;    // size of scaled image to fit in texture map
	GLfloat _txShowNormal[8];
	GLfloat _txShowMirror[8];
	GLfloat _txPassthru[8];
}

@property(readonly) CGSize margin;

- (id)initWithVideoDimensions:(CGSize)videoDimensions_ screenSize:(CGSize)screenSize_;
- (void)drawPixType:(DrawPixType)type mirror:(bool)mirror position:(GLint)position texCoord:(GLint)texCoord;

void makeQuads(float *showNormal,  
               float *showMirror, 
               float *passthru,
               float a, float b, 
               float c, float d, 
               float e, float f, 
               float g, float h);

@end

