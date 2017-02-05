
#import "Shader+Error.h"
#import "AppDelegate.h"
#import "MuEditTextVC.h"
#import "MuNavigationC.h"

@implementation LineKey
@synthesize line,key;
@end

@implementation Shader (Error)

#define VertexShaderProblemTitle NSLocalizedString( @"Vertex Shader Problem", nil)
#define FragmentShaderProblemTitle NSLocalizedString( @"Fragment Shader Problem", nil)

- (void) errorForShader:(GLuint*)shader type:(GLenum)type {

    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        
        GLchar *log = (GLchar*)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSString *logString =[NSString stringWithUTF8String:log];
        _lineKey = [self parseErrorLog:logString];
        free(log);
        
        //title is tested by alertView:clickedButtonAtIndex:
        NSString *title = (type==GL_VERTEX_SHADER
                           ? VertexShaderProblemTitle
                           : FragmentShaderProblemTitle);
        
        [[UIAlertView.alloc initWithTitle:title message:logString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Edit",nil] show];
    }
    
}
- (LineKey*) parseErrorLog:(NSString*)errorLog {
    
    //@"ERROR: 0:20: Call to undeclared function 'texture'\n
    //           20                               texture
    
    NSError *error;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"ERROR: [0-9][:]([0-9]*).*[']([a-zA-Z0-9]*)[']" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRange range =NSMakeRange(0, [errorLog length]);
    NSArray *matches = [re matchesInString:errorLog options:NSMatchingHitEnd range:range];
    if ([matches count]<1)
        return nil;
    NSTextCheckingResult *result = [matches objectAtIndex:0];
    if (result.numberOfRanges==3) {
        
        for (int i = 1; i<result.numberOfRanges; i++) {
            NSRange rangei = [result rangeAtIndex:i];
            NSLog (@"%@",[errorLog substringWithRange:rangei]);
        }
        
        LineKey *lineKey = [LineKey.alloc init];
        NSString *lineNum = [errorLog substringWithRange:[result rangeAtIndex:1]];
        NSString *keyword = [errorLog substringWithRange:[result rangeAtIndex:2]];
        lineKey.line = [lineNum integerValue];
        lineKey.key = keyword;
        return lineKey;
    }
    return nil;
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==1) {
        
        if ([alertView.title isEqual:VertexShaderProblemTitle]) {
            
            [self editText:_vertex lineKey:_lineKey];
        }
        else if ([alertView.title isEqual:FragmentShaderProblemTitle]) {
            
            [self editText:_fragment lineKey:_lineKey];
        }
    }
}

- (void)editText:(NSString*)text lineKey:(LineKey*)lineKey {
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CGRect frame = app.window.bounds;
    
    NSArray *keys = [NSArray.alloc initWithObjects:lineKey.key, nil];
    MuEditTextVC *nextView = [MuEditTextVC.alloc initWithFrame:frame text:text keys:keys];
    
    [app.muNavC setNavigationBarHidden:NO animated:YES];
    [app.muNavC pushViewController:nextView animated:YES];
}

@end
