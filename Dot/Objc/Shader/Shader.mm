
#import "Shader+Tr3.h"
#import "Shader+Compile.h"
#import "Shader+Error.h"
#import "ShaderVertex.h"
#import "ShaderTexture.h"
#import "ShaderUniform.h"

@implementation Shader

+ (Shader*) named:(NSString*)name {
    
    static NSMutableDictionary *shaders = nil;
    if (!shaders) {
        shaders = [NSMutableDictionary.alloc init];
    }
    Shader *shader = [shaders objectForKey:name];
    if (!shader) {
        shader = [Shader.alloc initWithName:name];
        [shaders setObject:shader forKey:name];
    }
    return shader;
}


- (id)initWithName:(NSString*)name {
    
    self = [super init];
    _program = -1;
    _name = name.copy;
    _uniforms = NSMutableDictionary.alloc.init;
    _textures = [NSMutableDictionary.alloc init];
    _texCount = 0;
    _loaded = NO;
    return self;
}

- (bool)setVertex:(NSString*)vertex_ fragment:(NSString*)fragment_ {
    
    if (vertex_.length<1 || fragment_.length<1) {
        return false;
    }
    
 	GLuint vertShader, fragShader;
	// program
	_program = glCreateProgram();
    
    self.vertex = vertex_;
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER source:_vertex]) {
        destroyShaders(vertShader, fragShader, _program);
        fprintf(stderr,"\n*** failed to compile vertex shader for: %s\n",_name.UTF8String);
        return false;
    }
    
    self.fragment = fragment_;
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER source:_fragment]) {
		destroyShaders(vertShader, fragShader, _program);
                fprintf(stderr,"\n*** failed to compile fragment shader for: %s\n",_name.UTF8String);
		return false;
	}
    // attach
	glAttachShader(_program, vertShader);
	glAttachShader(_program, fragShader);
	
    // link
	if (!linkProgram(_program)) {
        
		destroyShaders(vertShader, fragShader, _program);
        _loaded = NO;
        fprintf(stderr,"\n*** failed to link shader for: %s\n",_name.UTF8String);
		return false;
	}
    
    // standard attributes for all shaders
    _aPosition = glGetAttribLocation (_program,"aPosition");
    _aTexCoord = glGetAttribLocation (_program,"aTexCoord");
    
    // cleanup
	if (vertShader) {
        
		glDeleteShader(vertShader);
		vertShader = 0;
	}
	if (fragShader) {
        
		glDeleteShader(fragShader);
		fragShader = 0;
	}
    _loaded = YES;
    
    return true;
}

- (void)printShader {
    
    fprintf(stderr, "*** shader:%s program:%i textures:",_name.UTF8String, _program);
    for (NSString*key in _textures.allKeys) {
        fprintf(stderr," %s",key.UTF8String);
    }
    fprintf(stderr, " uniforms:");
    for (NSString*key in _uniforms.allKeys) {
        fprintf(stderr," %s",key.UTF8String);
    }
    fprintf(stderr,"\n");
}

- (void)setFloat:(CGFloat)num name:(NSString*)name {
    
    ShaderUniform *uniform = [_uniforms objectForKey:name];
    if (!uniform) {
        uniform = [ShaderUniform.alloc initWithProgram:_program name:name];
        [_uniforms setObject:uniform forKey:name];
    }
    [uniform setFloat:num];
}

- (void)setPoint:(CGPoint)point name:(NSString*)name {
    
    ShaderUniform *uniform = [_uniforms objectForKey:name];
    if (!uniform) {
        uniform = [ShaderUniform.alloc initWithProgram:_program name:name];
        [_uniforms setObject:uniform forKey:name];
    }
    [uniform setPoint:point];
}


- (void)setPal:(void*)palBuf name:(NSString*)name {

    if (!palBuf)
        return;
    
    ShaderTexture *texture = [_textures objectForKey:name];
    if (!texture) {
        texture = [ShaderTexture.alloc initWithProgram:_program name:name num:_texCount++];
        [_textures setObject:texture forKey:name];
    }
    [texture setPal:palBuf];
}

- (void)setVid:(void*)vidBuf name:(NSString*)name {
    
    if (!vidBuf)
        return;
    
    ShaderTexture *texture = [_textures objectForKey:name];
    if (!texture) {
        texture = [ShaderTexture.alloc initWithProgram:_program name:name num:_texCount++];
        [_textures setObject:texture forKey:name];
    }
    [texture setVid:vidBuf];
}


- (void)bindTexCache:(CVOpenGLESTextureCacheRef)vidCache {
    
    glUseProgram(_program); 
    NSArray *uniformValues = [_uniforms allValues];
    
    for (ShaderUniform *uniform in uniformValues) {
         [uniform render];
    }
    NSArray *textures = [_textures allValues];
    for (ShaderTexture *texture in textures) {
        [texture bindTexCache:vidCache];
    }
}

- (void)drawVertex:(ShaderVertex*)vertex pixType:(DrawPixType)pixType mirror:(bool)mirror {
    
    [vertex drawPixType:pixType mirror:mirror position:_aPosition texCoord:_aTexCoord];
}

- (void)flush {
    
    NSArray *textures = [_textures allValues];
    for (ShaderTexture *texture in textures) {
        [texture flush];
    }
}

- (CVOpenGLESTextureRef)textureForName:(NSString*)name {
    
    ShaderTexture *texture = [_textures objectForKey:name];
    if (texture) {
        return texture.texture;
    }
    return nil;
}


@end
