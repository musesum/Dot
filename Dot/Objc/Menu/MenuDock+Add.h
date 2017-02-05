
#import "MenuDock.h"

struct Tr3;

@interface MenuDock (Add)

- (void)addSkyRoot:(Tr3*)skyRoot;

- (void)initDock:(NSString*)dock;

- (void)splashWithCompletion:(CompletionVoid)completion;

@end
