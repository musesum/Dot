
#import "Shader+Tr3.h"
#import "Tr3.h"
#import "CallIdSel.h"
#import "ShaderUniform.h"

@implementation Shader (Tr3)

+ (void)initShaderNamed:(NSString*)name tr3:(Tr3*)tr3 {
    
    Tr3* shaderTr3 = tr3->findChild("shader");
    if (shaderTr3) {
        Shader* shader = [Shader named:name];
        [shader initShaderTr3:shaderTr3];
        [shader printShader];
    }
}

- (void)addTr3Uniforms:(Tr3*)opengl {
    Tr3* uniforms = opengl->findChild("uniform");
    if (uniforms) {
        
        for (Tr3*uniTr3 : uniforms->children) {
            Tr3Val* val = uniTr3->val;
            if (val) {
                string& name = uniTr3->name;
                ShaderUniform* uniform = [ShaderUniform.alloc initWithProgram:_program cname:name.c_str()];
                uniTr3->addCall((Tr3CallTo)(&Tr3ShaderCallback), (void*)new CallIdSel(self));
                if (val->flags.tupple) {
                    Tr3ValTupple* tup = (Tr3ValTupple*)val;
                    int size = tup->vals.size();
                    if (size==2) {
                        Tr3ValScalar* xx = (Tr3ValScalar*)(tup->vals[0]);
                        Tr3ValScalar* yy = (Tr3ValScalar*)(tup->vals[1]);
                        CGPoint point = CGPointMake(xx->num, yy->num);
                        [uniform setPoint:point];
                        [_uniforms setObject:uniform forKey:[NSString stringWithUTF8String:name.c_str()]];
                    } else {
                        fprintf(stderr, "Shader+Tr3:%s unexpected tupple size:%i", name.c_str(),size);
                    }
                }
                else if (val->flags.scalar) {
                    Tr3ValScalar* scalar = (Tr3ValScalar*)val;
                    [uniform setFloat:scalar->num];
                     [_uniforms setObject:uniform forKey:[NSString stringWithUTF8String:name.c_str()]];
                }
                else {
                    fprintf(stderr, "Shader+Tr3:%s unknown flags:%i", name.c_str(),val->flags.all);
                }
            }
        }
    }
}



- (void) initShaderTr3:(Tr3*)shaderTr3 {

    Tr3* fsh = shaderTr3->findChild("fragment"); // fragment
    Tr3* vsh = shaderTr3->findChild("vertex"); // vertex
    
    if (fsh && fsh->val && fsh->val->flags.quote &&
        vsh && vsh->val && vsh->val->flags.quote ) {
        
        Tr3ValQuote* fragQ = (Tr3ValQuote*)(fsh->val);
        Tr3ValQuote* vertQ = (Tr3ValQuote*)(vsh->val);
        
        NSString* frag = [NSString stringWithUTF8String:fragQ->getWithinCurly().c_str()];
        NSString* vert = [NSString stringWithUTF8String:vertQ->getWithinCurly().c_str()];
        if ([self setVertex:vert fragment:frag]) {
            [self addTr3Uniforms:shaderTr3];
        }
    }

}

#pragma mark - shader callback

void Tr3ShaderCallback(Tr3*from,Tr3CallData*data) {
    
    __block id target = (__bridge id)(data->_instance);
    dispatch_async(dispatch_get_main_queue(), ^{
        [target updateShaderTr3:from];
    });
}

-(void)updateShaderTr3:(Tr3*)uniform {
    
    NSString* name = [NSString stringWithUTF8String: uniform->name.c_str()];
    
    if (uniform->val->flags.tupple) {
        CGPoint point = CGPointMake(uniform[0], uniform[1]);
        [self setPoint:point name:name];
    }
    else if (uniform->val->flags.scalar) {
        Tr3ValScalar* val = (Tr3ValScalar*)uniform->val;
        CGFloat value = *uniform;
        [self setFloat:value name:name];
    }
}


@end
