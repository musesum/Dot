//
//  Shader+Shader_Error.h
//  Dot
//
//  Created by warren on 2/4/17.
//  Copyright © 2017 Muse. All rights reserved.
//

#import "Shader.h"

@interface LineKey : NSObject
@property (nonatomic,assign)int line;
@property (nonatomic,strong)NSString *key;
@end

@interface Shader (Error)
- (void) errorForShader:(GLuint*)shader type:(GLenum)type;
- (LineKey*) parseErrorLog:(NSString*)errorLog;
@end
