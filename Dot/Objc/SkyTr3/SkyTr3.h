#import "CellMain.h"
#import "SoundEffect.h"
#import "ParPar.h"
#import "Tr3Expand.h"

struct Tr3;

@interface SkyTr3 : NSObject {

    BOOL _pushSkyActive;
    Tr3* _tr3CellGo;        // execute cellular automata
    Tr3* _tr3CellNow;      // current CA rule - lowercase
    Tr3* _tr3Shake;
    Tr3* _tr3PalChangeMix;

    ParPar _parPar;
    
    bool _eraseUniverse;
}

//@property(nonatomic) ImageFromType imageFrom;
@property(nonatomic) CellMain *cellMain;
@property(nonatomic) CGSize skySize;
@property(nonatomic) BOOL skyActive;

+ (id)shared;

- (void)openDotURL:(NSURL*)url;
- (void)parseTr3:(NSString*)tr3;

// active state
- (void)setSkyActive:(BOOL)skyActive_;
- (void)pushSkyActive:(BOOL)skyActive_;
- (void)popSkyActive:(BOOL)skyActive_;

// shake gesture
void Tr3Shake(Tr3*from,Tr3CallData*data);
- (void)erase;
- (void) checkEraseUniverse;

@end
