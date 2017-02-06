
#import "SkyTr3.h"
#import "Tr3.h"
#import "SkyTr3Root.h"
#import "CallIdSel.h"
#import "Tr3Script.h"
#import "NSFile.h"

#define PrintSkyMain(...) // DebugPrint(__VA_ARGS__)

@implementation SkyTr3

#pragma mark - init

+(SkyTr3*) shared {
    
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [self.alloc init];
    });
    return shared;
}

- (id)init {
    
    self = [super init];
    
    _skyActive = NO;
    _pushSkyActive = NO;
    
    [NSFile copyDir:@"tr3"];//[self seedFirstTimeStartup];
    [self parseScripts];
    [self setupSkySize:CGSizeMake(1280/4,720/4)]; // 720p
    [self initCellularAutomataPipeline];
    return self;
}

#pragma mark - Active State

- (void)setSkyActive:(BOOL)active {
    
    _skyActive = active;
    if (active) {
        _tr3CellGo->setNow(1.);
        _tr3PalChangeMix->bang();
    }
}
- (void)pushSkyActive:(BOOL)skyActive_ {
    
    _tr3CellGo->setNow(skyActive_);
    _pushSkyActive = _skyActive;
    [self setSkyActive:skyActive_];
}
- (void)popSkyActive:(BOOL)skyActive_ {
    _tr3CellGo->setNow(_pushSkyActive);
    [self setSkyActive:_pushSkyActive];
}

//TODO: this is a new format url that replaces openPatchURL
- (void)openDotURL:(NSURL*)url {
    if (!url) {
        return;
    }
    assert("openDotURL:(NSURL*)url not implemented yet");
 }


- (void)setupSkySize:(CGSize)size_ {
    
    // camera has landscape orientation
    CGSize screenSize = UIScreen.mainScreen.fixedCoordinateSpace.bounds.size;
    
    for (int i=1; i<=8; i++) {
        CGFloat ii = i;
        CGFloat maxi = MAX(screenSize.width/ii, screenSize.height/ii);
        if (568 >= maxi) {
            _skySize = CGSizeMake(screenSize.height/i,
                                  screenSize.width/i);
            break;
        }
    }
    _skySize = size_;
}

// initialize CellularAutomata pipeline
- (void)initCellularAutomataPipeline {

    _cellMain = new CellMain(SkyRoot,0,_skySize.width,_skySize.height,4);
    
    // setup program loop for Sky
    Tr3* sky         = SkyRoot->bind("sky");
    _tr3CellGo       = sky->bind("cell.go");
    _tr3CellNow      = sky->bind("cell.now");
    _tr3PalChangeMix = sky->bind("pal.change.mix");
    
    // setup shake gesture to erase
    Tr3 *input = sky->bind("input");
    _tr3Shake = input->Tr3Bind2("shake", Tr3Shake );
 }

/*read the grammar for parsing in tr3 scripts
 */
- (void) parseTr3Path:(NSString*)path name:(NSString*)name {
    NSString* pathName = [NSString stringWithFormat:@"%@%@",path,name];
    const char* buf = [NSFile readPath:path name:name ext:@"tr3"];
    _parPar.addBuf2Tokens(buf,stderr);
}

/* callback that prints changes in Tr3 nodes values
 * see testTernary()
 */
void Tr3Callback(Tr3*tr3,Tr3CallData*ignored) {
    
    if (tr3->val) {
        
        if (tr3->val->flags.scalar) {
            fprintf(stderr," %s:%g ",tr3->parentPath(2),((Tr3ValScalar*)tr3->val)->num);
            return;
        }
        else {
            string s;
            Tr3Print::printVal(s,"",tr3->val);
            fprintf(stderr," %s:%s ",tr3->parentPath(2),s.c_str());
            return;
        }
    }
    fprintf(stderr," %s! ",tr3->parentPath());
}

- (void)parseScripts {
    const char *tr3Par = [NSFile readPath:@"tr3/par" name:@"tr3" ext:@"par"]; 
    _parPar.parBuf2Grammar(tr3Par,stderr);
    
#define ParseFile(A)  [self parseTr3Path:@"tr3" name:@#A];
    ParseFile(sky/main)
    ParseFile(sky/input)
    ParseFile(sky/screen)
    ParseFile(sky/cell)
    ParseFile(sky/pal)
    ParseFile(sky/osc)
    ParseFile(sky/draw)
    ParseFile(sky/time)
    ParseFile(sky/recorder)
    
    ParseFile(dot/_dot)
    ParseFile(dot/_cellRule)
    ParseFile(dot/shader.tile)
    ParseFile(dot/shader.weave)
    ParseFile(dot/cell.shift)
    ParseFile(dot/cell.rule.add)
    ParseFile(dot/cell.rule.melt)
    ParseFile(dot/sky.brush)
    ParseFile(dot/pal.main)
    ParseFile(dot/pal.rainbow)
    ParseFile(dot/dot.connect) // aways last to connect ruleOn, value state between dots

    _parPar.finalize();
    
    Tr3Expand::expandRoot(SkyRoot,&_parPar.tokTree);
    Tr3Expand::mergeDuplicates(SkyRoot);
    Tr3Script::PrintTr3(stderr, SkyRoot, PrintFlags(kTr3Id|kEdges|kInstance));
    
#if 0
    Tr3* brushTiltV = SkyRoot->bind("dot.cell.shift.controls.brushTilt.value",(Tr3CallTo)(&Tr3Callback), 0);
    Tr3* accelTiltV = SkyRoot->bind("dot.cell.shift.controls.accelTilt.value",(Tr3CallTo)(&Tr3Callback), 0);
    Tr3* shiftBoxV  = SkyRoot->bind("dot.cell.shift.controls.shiftBox.value",(Tr3CallTo)(&Tr3Callback), 0);
    Tr3* shiftBoxM  = SkyRoot->bind("dot.cell.shift.controls.shiftBox.master",(Tr3CallTo)(&Tr3Callback), 0);
    
    fprintf(stderr, "\n*** %16s ⟶","shiftBoxV!");  shiftBoxV->setNow(1.);
    fprintf(stderr, "\n*** %16s ⟶","brushTiltV:1"); brushTiltV->setNow(1.);
    fprintf(stderr, "\n*** %16s ⟶","accelTiltV:1"); accelTiltV->setNow(1.);
    fprintf(stderr, "\n*** %16s ⟶","shiftBoxV:1");  shiftBoxV->setNow(1.);
    fprintf(stderr, "\n*** %16s ⟶","brushTiltV:1"); brushTiltV->setNow(1.);
    fprintf(stderr, "\n\n");
#endif

}

- (void)parseTr3:(NSString*)tr3Buf {
    
    if (tr3Buf.length==0) {
        return;
    }
    const char *buf2 = [tr3Buf UTF8String];
    
    _parPar.txtBuf2Tokens(buf2,stderr);
    Tr3Expand::expandRoot(SkyRoot,&_parPar.tokTree);
    Tr3Expand::mergeDuplicates(SkyRoot);
    Tr3Script::PrintTr3(stderr, SkyRoot, PrintFlags(kValues));
}
#pragma mark - Erase Gesture

void Tr3Shake(Tr3*from,Tr3CallData*data) {
    
    id target = (__bridge id)(data->_instance);
    [target erase];
}

- (void)erase {
    
    _eraseUniverse = YES;
    NSLog(@"* erase *");
}

- (void) checkEraseUniverse {
    if (_eraseUniverse) {
        _eraseUniverse = NO;
        static Tr3 *zero = 0;
        if (!zero) {
            zero = SkyRoot->bind("cell.rule.zero");
        }
        zero->bang();
    }
}
@end
