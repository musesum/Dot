
#import "SkyMain.h"
#import "SkyPatch.h"
#import "ScreenView.h"
#import "UIExtras.h"
#import "VideoManager.h"
#import "SkyTr3Root.h"
#import "MenuDock+add.h"

#define PrintSkyMain(...) // DebugPrint(__VA_ARGS__)

using namespace std;

@implementation SkyMain (Patch)

#pragma mark - File

- (void)openPatchURL:(NSURL*)url {
    if (!url) {
        return;
    }
    SkyPatch *patch;
    
    NSString *URLString = [url absoluteString];
    if(URLString) {
        
        NSString *last = [[url path] lastPathComponent];
        patch = [SkyPatch unzipName:last path:[url path] withUniverse:YES];
    }
    else {
        patch =  [SkyPatch readPatchName:@"Placemark" withUniverse:YES];
    }
    [self parseTr3:patch.tr3Buf];
    [self parsePatch:patch];
}

- (NSString*)saveImage:(UIImage*)image {
    
    NSString *documentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *imageFile = [documentsDir stringByAppendingPathComponent:@"image.png"];
    NSError *error = nil;
    NSData *imagePngData = UIImagePNGRepresentation(image);
    [imagePngData writeToFile:imageFile options:NSAtomicWrite error:&error];
    return imageFile;
}

#pragma mark - placmark
#if 0
- (NSString*)savePatch:(SHKItem*)item {

    bool hasUniverse = YES; //[item customBoolForSwitchKey:@"Universe"];
    bool hasSettings = YES; //[item customBoolForSwitchKey:@"Settings"];
    bool hasPalette  = YES; //[item customBoolForSwitchKey:@"Palette"];
    bool hasDock     = NO; //[item customBoolForSwitchKey:@"Dock"];
    UIImage *thumb;
    
    if (hasUniverse || !hasPalette) {
        
        thumb = [item.image imageByScalingAndCroppingForSize:CGSizeMake(82, 82)];
    }
    else {
        
        Pals &pals = (self.cellMain->pic.pix.pals);
        UIImage *pal0   = [UIImageRgbs imageFromRgbs:&(pals.pal[0].rgbs) size:CGSizeMake(82, 22)];
        UIImage *pal1   = [UIImageRgbs imageFromRgbs:&(pals.pal[1].rgbs) size:CGSizeMake(82, 22)];
        UIImage *palf   = [UIImageRgbs imageFromRgbs:&(pals.final)       size:CGSizeMake(82, 36)];
        UIImage *pal0f  = [pal0  imageAddBelowImage:palf withBorder:YES];
        UIImage *pal0f1 = [pal0f imageAddBelowImage:pal1 withBorder:YES];
        thumb = [pal0f1 imageByScalingAndCroppingForSize:CGSizeMake(82, 82)];
    }
    
    UIImage *button =(hasUniverse ?
                      [UIImage imageNamed:@"dot.ring.white.png"] :
                      [UIImage imageNamed:@"dot.ring.white.png"]);
    
    UIImage *buttonThumb = [button imageAddImage:thumb under:NO];
    
    NSData   *universe = (hasUniverse ? [self getSkyUniverse]   : nil);
    NSData   *pal1Data = (hasPalette  ? [self getSkyPal:0]      : nil);
    NSData   *pal2Data = (hasPalette  ? [self getSkyPal:1]      : nil);
    Shader   *shader = [ScreenView shared].shaderNow;
    NSString *dock = nil;
    NSString*  skyType = @"user";
    
    if (hasDock) {
        
        dock = [self getDock];
        skyType = @"placemark";
        
        //new UIImage *imagePearl = [UIImage imageNamed:@"diamond_32.png"];//prl Pearl_32
        UIImage *imagePearl = [UIImage imageNamed:@"Pearl_32.png"];//prl Pearl_32
        buttonThumb = [buttonThumb imageAddLowerLeftImage:imagePearl];
    }
    else if (hasPalette && !hasUniverse && !hasSettings) {
        
        skyType = @"palette";
    }
    NSData  *thumbPngData = UIImagePNGRepresentation(buttonThumb);
    
    return [SkyPatch saveFile:item.file.filename
                       shader:shader
                     universe:universe
                        thumb:thumbPngData
                         pal1:pal1Data
                         pal2:pal2Data
                         dock:dock
                         info:nil
                      skyType:skyType
                    overwrite:NO];

    return @"";
}
#endif

- (void)saveSystemPlacemark {
    
    UIImage *image = [ScreenView.shared glScreenshot];
    [ScreenView.shared clearImageBufferForGlScreenshot];
    UIImage *thumbImg = [image imageByScalingAndCroppingForSize:CGSizeMake(82, 82)];
    UIImage *btnImage = [UIImage imageNamed:@"dot.ring.roygbiv.png"];
    UIImage *thumbBtn = [btnImage imageAddImage:thumbImg under:NO];
    NSData *thumbData = UIImagePNGRepresentation(thumbBtn);
    
    NSData   *universe = [self getSkyUniverse];
    NSData   *pal1     = [self getSkyPal:0];
    NSData   *pal2     = [self getSkyPal:1];
    NSString *dock     = [self getDock];
    Shader *shaderNow  = [ScreenView shared].shaderNow;
    
    [SkyPatch saveFile:@"  Placemark"
                shader:shaderNow
              universe:universe
                 thumb:thumbData
                  pal1:pal1
                  pal2:pal2
                  dock:dock
                  info:nil
               skyType:@"placemark"
             overwrite:YES];
}

#pragma mark - images

- (NSString*)filenameFromImageType:(ImageFromType)type_ {
    
    self.imageFrom = type_;
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName= @"default.data";
    
    switch (type_) {
            
        case kImageFromCamera:          fileName = @"camera.data";      break;
        case kImageFromAlbum:           fileName = @"album.data";       break;
        case kImageFromRenderBuffer:    fileName = @"buffer.data";      break;
        case kImageFromUniverse:        fileName = @"universe.data";    break;
        case kImageBlank: default:      fileName = @"default.data";     break;
    }
    NSString *fullPath = [docPath stringByAppendingPathComponent:fileName];
    return fullPath;
}

- (void)readImageFromType:(ImageFromType)imageFrom_ {
    
    NSString *filename = [self filenameFromImageType:imageFrom_];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    
    switch (imageFrom_) {
            
        case kImageFromAlbum:
        case kImageFromCamera:
            
            self.cellMain->pic.copyRgbaToMonoUniv((void*)[data bytes],YES); //vp prl
            break;
            
        case kImageFromUniverse:
            
            self.cellMain->pic.copyDataToUniv((void*)[data bytes]); //vp prl
            break;
            
        default:
            
            break;
    }
}
- (void)readLastImage {
    
    [self readImageFromType:self.imageFrom];
    
}
- (NSString*)filenameForLastImageFrom {
    
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fullPath = [docPath stringByAppendingPathComponent:@"lastImageFrom"];
    return fullPath;
}

- (void)writeLastImageFromType {
    ImageFromType type = self.imageFrom;
    NSData *data = [NSData dataWithBytes:&type length:sizeof(type)];
    [data writeToFile:[self filenameForLastImageFrom] atomically:YES];
}

- (void)writeData:(NSData*)data imageFrom:(ImageFromType)imageFrom_ {
    
    self.imageFrom = imageFrom_;
    [self writeLastImageFromType];
    NSString *filename = [self filenameFromImageType:self.imageFrom];
    [data writeToFile:filename atomically:YES];
}

#pragma mark - Parse

- (void)setPatchNow:(SkyPatch*)patch {
    
    _tr3CellNow->setNow(patch.name.lowercaseString.UTF8String);
    if (patch.shaderVsh.length > 0 && patch.shaderFsh.length > 0) {
        [ScreenView.shared setShaderPatch:patch];
    }
}

- (void)parsePatch:(SkyPatch*)patch {
    
    if (patch.shaderName && [patch.shaderName length]>0) {
        [ScreenView.shared addShaderPatch:patch];
    }
    if (patch.universe) {
        
        float skyLength = self.skySize.width*self.skySize.height*4;
        float uniLength = [patch.universe length];
        void* buf = (void*)[patch.universe bytes];
        
        if (uniLength != skyLength) {
            
            /* TODO: copy into buffer either clipped or centered. the routines are already there in Buf, need to tweak.
             * CellMain::init -> Pic::init to include source and destination size
             */
            self.cellMain->init(SkyRoot,0,self.skySize.width,self.skySize.height,4);
        }
        else {
            self.cellMain->init(SkyRoot,buf,self.skySize.width,self.skySize.height,4);
        }
    }
}

- (bool)parsePalFromPatch:(SkyPatch*)patch {
    
    bool paletted = NO;
    
    if (patch.pal1) {
        
        paletted = YES;
        Rgbs *rgbs = &(self.cellMain->pic.pix.pals.pal[0].rgbs);
        int length = [patch.pal1 length];
        int size = length / sizeof(Rgb);
        rgbs->resizeRgb(size);
        memcpy(rgbs->_rgbArray,(byte*)[patch.pal1 bytes],length);
    }
    if (patch.pal2) {
        
        paletted = YES;
        Rgbs *rgbs = &(self.cellMain->pic.pix.pals.pal[1].rgbs);
        int length = [patch.pal1 length];
        int size = length / sizeof(Rgb);
        rgbs->resizeRgb(size);
        memcpy(rgbs->_rgbArray,(byte*)[patch.pal2 bytes],length);
    }
    return paletted;
}


#pragma mark - Tr3 Settings

- (NSString*)addTr3Placemark:(Tr3*)tr3 settings:(NSString*)settings {
    
    if (tr3->val) {
        
        NSString *item = nil;
        if (tr3->val->flags.quote) {
            
            item = [NSString stringWithFormat:@"tr3Quote %s %s\n",
                    tr3->parentPath(),
                    ((Tr3ValQuote*)tr3->val)->quote.c_str()];
        }
        else {
            
            item = [NSString stringWithFormat:@"tr3Num %s %f\n",
                    tr3->parentPath(),
                    ((Tr3ValScalar*)tr3->val)->num];
            
        }
        
        PrintSkyMain("%s",[item UTF8String]);
        settings = [settings stringByAppendingString:item];
        
    }
    return settings;
}
- (NSString*)getTr3AlwaysSettings:(NSString*)settings {
    
    Tr3*tr3 = SkyRoot->bind("main.dot.placemark.always");
    
    for (Tr3Edge* edge : tr3->edgeGroup.edges) {
        
        if (edge->flags.find) {
            
            Tr3*rght = edge->rght;
            
            [self addTr3Placemark:rght settings:settings];
            //PrintSkyMain("%i ",tr3->_act);
        }
    }
    return settings;
}

#pragma mark - Patch values

- (NSData*)getSkyPal:(int) index {
    
    Pals*pals = &(self.cellMain->pic.pix.pals);
    Rgbs*rgbs = &(pals->pal[index].rgbs);
    int bufSize = (int) (rgbs->_rgbNow*4);
    byte *buf = (byte*)malloc(bufSize);
    memcpy (buf,rgbs->_rgbArray,bufSize);
    
    NSData *data = [NSData dataWithBytesNoCopy:buf length:bufSize];
    return data;
}

- (NSData*)getSkyUniverse {
    
    int bufSize = (int) (self.skySize.width*self.skySize.height*4);
    int *buf = (int*)malloc(bufSize);
    self.cellMain->pic.univ.copyFromPrev(buf,self.skySize.height,self.skySize.width); //vp
    
    NSData *picture = [NSData dataWithBytesNoCopy:buf length:bufSize];
    return picture;
}

- (NSString*)getDock {
    
    NSString *dock = [NSString stringWithFormat:@""];
    
    MenuDock *menuDock = MenuDock.shared;
    
    if (_videoManager.captureFlags & kDeviceCaptureCameraFront) {
        
        dock = [dock stringByAppendingString:@"cameraFront\n"];
    }
    else if (_videoManager.captureFlags & kDeviceCaptureCameraBack) {
        
        dock = [dock stringByAppendingString:@"cameraBack\n"];
    }
    for (MenuParent *button in menuDock.parents) {
        
        if (button.name) {
            
            NSString *last = [button.name lastPathComponent];
            
            if (button == menuDock.parentNow) {
                
                dock = [dock stringByAppendingFormat:@"*/%@\n",last];
            }
            else {
                dock = [dock stringByAppendingFormat:@"/%@\n",last];
            }
        }
    }
    return dock;
}

// caller: MenuChild(Camera|Album)
- (void)advanceWithImage:(UIImage*)image rect:(CGRect)sourceRect imageType:(ImageFromType)imageFrom_ {
    
    //copy into texture map
    CGRect destRect = CGRectMake(0, 0, self.skySize.width, self.skySize.height);
    NSData *data = [image dataFromImageScaledToSizeWithSameAspectRatio:destRect.size];
    self.cellMain->pic.copyRgbaToMonoUniv((void*)[data bytes],YES); //vp ss
    
    //save to file
    [self writeData:data imageFrom:imageFrom_];
    [self NextFrame];//TODO: also called by WorkLink with not processing video
}


// extra

- (SkyPatch*)parsePlacemark {
    
    //reinstate from placemark
    SkyPatch* patch = [SkyPatch readPatchName:@"Placemark" withUniverse:YES];
    SkyMain* skyMain = SkyMain.shared;
    [skyMain parsePatch:patch];
    [skyMain parsePalFromPatch:patch];
    [skyMain parseTr3:patch.tr3Buf];
    [ScreenView.shared setShaderPatch:patch];
    return patch;
}


@end
