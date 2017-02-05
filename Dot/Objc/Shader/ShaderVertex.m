

#import "ShaderVertex.h"

#define kMaxTextureSize	 1024

#define LogTexture2D(...) // DebugLog(__VA_ARGS__) 
#define PrintTexture2D(...) DebugPrint(__VA_ARGS__) 

@implementation ShaderVertex

@synthesize margin = _margin;

- (id)init {
    
    self = [super init];
    return self;
}


void makeQuads(float *showNormal,  
               float *showMirror, 
               float *passthru,
               float a, float b, 
               float c, float d, 
               float e, float f, 
               float g, float h) {
    
#define Set(Z,A,B,C,D,E,F,G,H) Z[0]=A; Z[1]=B; Z[2]=C; Z[3]=D; Z[4]=E; Z[5]=F; Z[6]=G; Z[7]=H;
    
    Set(showNormal , a,b, c,d, e,f, g,h ) 
    Set(showMirror , e,f, g,h, a,b, c,d )
    Set(passthru   , a,b, c,d, e,f, g,h )

}

- (id)initWithVideoDimensions:(CGSize)videoDimensions_ screenSize:(CGSize)screenSize_ {
    
    _videoDimensions = videoDimensions_;
    _screenSize = screenSize_;
    
    float screenAspect = _screenSize.width/_screenSize.height;
    float imageAspect = _videoDimensions.height/_videoDimensions.width; //iOS rotates image
    if (imageAspect>screenAspect) {
        
        _margin.width = (1-(screenAspect/imageAspect))/2;
        _margin.height = 0;
     }
    else if (imageAspect<screenAspect){
        
        //TODO: untested
        _margin.width = 0;
        _margin.height = (1-(imageAspect/screenAspect))/2;
    }
    else {
        _margin.width = 0;
        _margin.height = 0; 
    }
 
    makeQuads(_txShowNormal,  
              _txShowMirror, 
              _txPassthru,
              
                _margin.height, 1-_margin.width,
              1-_margin.height, 1-_margin.width,
                _margin.height,   _margin.width,
              1-_margin.height,   _margin.width);

    return self;
}

- (void)drawVert:(GLfloat*)vert position:(GLint)position texCoord:(GLint)texCoord {

    glClearColor(0., 0., 0., 1.);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glVertexAttribPointer ( position, 3, GL_FLOAT, GL_TRUE, 5 * sizeof(GLfloat), vert ); // vert 
    glVertexAttribPointer ( texCoord, 2, GL_FLOAT, GL_TRUE, 5 * sizeof(GLfloat), &vert[3] ); // tx
    
    glEnableVertexAttribArray ( position );
    glEnableVertexAttribArray ( texCoord );
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

}


#define AttribPtr(A,B) glVertexAttribPointer (A, 2, GL_FLOAT, GL_TRUE, 2 * sizeof(GLfloat), B )

- (void)drawPixType:(DrawPixType)type
             mirror:(bool)mirror
           position:(GLint)position
           texCoord:(GLint)texCoord
{
        
    static const GLfloat vertex[] = { -1,1, -1,-1, 1,1, 1,-1}; // reverse N order:  |/|
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_TRUE, 2 * sizeof(GLfloat), vertex);
  
    
    if (type==kDrawPixWrite) {
        /* these are 1:1 pass onto write */
        
        static const GLfloat writeNormal[] = {0,1, 0,0, 1,1, 1,0}; // {0,0, 1,0, 0,1, 1,1};
        static const GLfloat writeMirror[] = {0,0, 0,1, 1,0, 1,1}; // recorded as mirrored
        
        // {1,0, 1,1, 0,0, 0,1}; // upside down
        // {1,1, 1,0, 0,1, 0,0}; // upside down
        // {0,1, 1,1, 0,0, 1,0}; // rotated counterclockwise
     
        glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_TRUE, 2 * sizeof(GLfloat),
                              mirror ? writeMirror : writeNormal);
        
    }
    else if (type==kDrawScreen2) {

        static const GLfloat screen2[] = {0,0, 0,1, 1,0, 1,1};
        // {1,1, 1,0, 0,1, 0,0}; //  rotate 180
        // {0,1, 0,0, 1,1, 1,0};  // upside down
        // {0,1, 1,1, 0,0, 1,0};  // rotate clock bad aspect
        // {1,0, 1,1, 0,0, 0,1};  // flip horizontal
        glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_TRUE, 2 * sizeof(GLfloat),screen2);
    }
    else {
        // _showNormal 0,.78, 1,.78  0,.22, 1,.22
        // _showMirror 0,.22, 1,.22, 0,.78, 1,.78
        
        /* test are scaled to fit texture within a viewport */
        glVertexAttribPointer(texCoord, 2, GL_FLOAT, GL_TRUE, 2 * sizeof(GLfloat), mirror ? _txShowMirror : _txShowNormal);
    }
    glEnableVertexAttribArray(position);
    glEnableVertexAttribArray(texCoord);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


@end
