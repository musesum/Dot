#import "main.h"

struct Tr3Osc;
struct Tr3;

@interface OscTr3 : NSObject {
    
    Tr3Osc* _tr3Osc;
}

+(OscTr3*) shared;
- (void)go;
- (id)initWithTr3:(Tr3*)tr3;

@end
