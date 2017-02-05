
#import "Shader.h"

@interface Shader (Compile)

- (GLint)compileShader:(GLuint*)shader
                  type:(GLenum)type
                source:(NSString*)source;
extern GLint compileShader(GLuint *shader, GLenum type, GLsizei count, NSString *file);
extern GLint linkProgram(GLuint prog);
extern GLint validateProgram(GLuint prog);
extern void destroyShaders(GLuint vertShader, GLuint fragShader, GLuint prog);

@end

