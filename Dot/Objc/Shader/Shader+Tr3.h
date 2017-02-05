
#import "Shader.h"

class Tr3;

@interface Shader (Tr3)

+ (void)initShaderNamed:(NSString*)name tr3:(Tr3*)tr3;
- (void)addTr3Uniforms:(Tr3*)uniforms;

@end

