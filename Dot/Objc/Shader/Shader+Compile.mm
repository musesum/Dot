
#import "Shader+Tr3.h"
#import "Shader+Error.h"

@implementation Shader (Compile)

- (GLint)compileShader:(GLuint*)shader
                  type:(GLenum)type
                source:(NSString*)source {
    
    GLint status;
    const GLchar *sources;
    
    // get source code
    sources = (GLchar*)[source UTF8String];
    if (!sources) {
        fprintf(stderr,"\n*** shader: Failed to load shader\n");
        return 0;
    }
    *shader = glCreateShader(type);				// create shader
    glShaderSource(*shader, 1, &sources, NULL);	// set source code in the shader
    glCompileShader(*shader);					// compile shader
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        [self errorForShader:shader type:type];
    }
    return status;
}


/* Create and compile a shader from the provided source(s) */
GLint compileShader(GLuint *shader, GLenum type, GLsizei count, NSString *file) {
    
    // get source code
    const GLchar *sources = (GLchar*)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!sources) {
        fprintf(stderr,"\n*** shader: Failed to load vertex shader\n");
        return 0;
    }
    
    *shader = glCreateShader(type);				// create shader
    glShaderSource(*shader, 1, &sources, NULL);	// set source code in the shader
    glCompileShader(*shader);					// compile shader
    
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        GLint logLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
        GLchar *log = (GLchar*)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        fprintf(stderr,"\n*** shader:  failed to compile. log:\n%s", log);
        free(log);
    }
    return status;
}

/* Link a program with all currently attached _shaders */
GLint linkProgram(GLuint prog) {
    
    glLinkProgram(prog);
    
    GLint status;
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        
        GLint logLength;
        glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
        GLchar *log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        fprintf(stderr,"\n*** shader: ailed to link program %d log:\n%s\n", prog, log);
        free(log);
    }
    return status;
}


/* Validate a program (for i.e. inconsistent samplers) */
GLint validateProgram(GLuint prog) {
    
    glValidateProgram(prog);
    
    GLint status;
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == GL_FALSE) {
        
        GLint logLength;
        glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
        GLchar *log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        fprintf(stderr,"\n*** shader: program validate prog: %d log:\n%s\n", prog,log);
        free(log);
    }
    return status;
}

/* delete shader resources */
void destroyShaders(GLuint vertShader, GLuint fragShader, GLuint prog) {
    
    if (vertShader) {
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDeleteShader(fragShader);
    }
    if (prog > -1) {
        glDeleteProgram(prog);
    }
}

@end
