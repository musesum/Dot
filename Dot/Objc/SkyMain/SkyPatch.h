#import "main.h"

typedef enum {
    
    kWithChangesAlways,
    kWithChangesNever,
    kWithChangesActive,
}   WithChangesType;

@class Shader;

@interface SkyPatch : NSObject
@property(nonatomic,strong) NSString* name;
@property(nonatomic,weak)   NSData*   universe;
@property(nonatomic,strong) NSString* shaderFsh;
@property(nonatomic,strong) NSString* shaderVsh;
@property(nonatomic,strong) NSString* shaderName;
@property(nonatomic,strong) NSString* tr3Buf;

@property(nonatomic,weak) NSData* thumb;
@property(nonatomic,weak) NSData* pal1;
@property(nonatomic,weak) NSData* pal2;
@property(nonatomic,weak) NSString* path;
@property(nonatomic,weak) NSString* dock;
@property(nonatomic,weak) NSString* skyType;


+ (SkyPatch*)unzipName:(NSString*)name
                  path:(NSString*)path
          withUniverse:(bool)universe;

+ (SkyPatch*)readPatchName:(NSString*)name
              withUniverse:(bool)universe;


+ (NSString*)saveFile:(NSString*)filename
               shader:(Shader*)shader
             universe:(NSData*)universeData
                thumb:(NSData*)thumbData 
                 pal1:(NSData*)pal1
                 pal2:(NSData*)pal2 
                 dock:(NSString*)dock
                 info:(NSString*)info
              skyType:(NSString*)skyType
            overwrite:(bool)overwrite;

@end
