#import "SkyPatch.h"
#import "ZipArchive.h"
#import "Shader.h"

#define LogSkyPatch(...)   // DebugLog(__VA_ARGS__)
#define PrintSkyPatch(...) // DebugPrint(__VA_ARGS__)

@implementation SkyPatch

#pragma mark - new save

#import "Tr3Find.h"
#import "Tr3Script.h"
#import "SkyTr3Root.h"

#include <string>
#include <cstdio>
#include <cerrno>

+ (NSString*)printTr3:(Tr3*)tr3 {
    
     string foundStr;
    
    FILE* tmp = std::tmpfile();
    Tr3Script::PrintTr3(tmp, tr3, PrintFlags(kValues));
    
    fseek(tmp, 0, SEEK_END);
    foundStr.resize(ftell(tmp));
    rewind(tmp);
    fread(&foundStr[0], 1, foundStr.size(), tmp);
    fclose(tmp);
    NSString *result = @(foundStr.c_str());
    
    return result;
}

- (NSString*)getTr3Path:(NSString*)path {

    string pathStr = [path UTF8String];;
    Tr3s found;
    Tr3::Find->findPath(SkyRoot, &pathStr, found);
    NSString *results = @"";
    
    for (Tr3 *tr3 : found) {
        NSString *result = [SkyPatch printTr3:tr3];
         results = [results stringByAppendingString:result];
    }
    return results;
}

+ (NSString*)saveFile:(NSString*)filename
               shader:(Shader*)shader
             universe:(NSData*)universeData
                thumb:(NSData*)thumbData
                 pal1:(NSData*)pal1
                 pal2:(NSData*)pal2
                 dock:(NSString*)dock
                 info:(NSString*)info
              skyType:(NSString*)skyType
            overwrite:(bool)overwrite {
    
    NSString *nomuse = [filename stringByReplacingOccurrencesOfString:@".muse" withString:@""];    
    NSString *docsDir  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString * fullPath= [NSString stringWithFormat:@"%@/%@.muse", docsDir,nomuse];
    NSFileManager *fileManager = [NSFileManager.alloc init];
    
    if (!overwrite) { // add a (1) etc to duplicate names
    
        for  (int i=1; [fileManager fileExistsAtPath:fullPath]; i++) {
            
            NSString *prev = (i==1 ? @".muse" : [NSString stringWithFormat:@"(%i).muse",i-1]);
            NSString *next = [NSString stringWithFormat:@"(%i).muse",i];
            fullPath = [fullPath  stringByReplacingOccurrencesOfString:prev withString:next];
        }
    }
    ZipArchive *zip = [ZipArchive.alloc init];
    
    if(![zip CreateZipFile2:fullPath]) {
        return nil;
    }
    
    for (Tr3* tr3 : SkyRoot->children) {
        
        NSString *branch = [self printTr3:tr3];
        NSData *data = [branch dataUsingEncoding:NSUTF8StringEncoding];
        NSString *name = [NSString stringWithFormat:@"%s.tr3",tr3->name.c_str()];
        [zip addDataToZip:data  date:[NSDate date] newname:name];
    }
    
    if (shader) {
        NSString *shaderName = shader.name;
        NSString *shaderVsh = shader.vertex;
        NSString *shaderFsh = shader.fragment;
        
        if (shaderName) {
            
            NSString * vertexFileName   = [NSString stringWithFormat:@"%@.vsh", shaderName];
            NSString * fragmentFileName = [NSString stringWithFormat:@"%@.fsh", shaderName];
            
            NSData *data = [shaderVsh dataUsingEncoding:NSUTF8StringEncoding];
            [zip addDataToZip:data  date:[NSDate date] newname:vertexFileName];
            
            data = [shaderFsh dataUsingEncoding:NSUTF8StringEncoding];
            [zip addDataToZip:data  date:[NSDate date] newname:fragmentFileName];
        }
    }
    if (dock) {
        
        NSData *data = [dock dataUsingEncoding:NSUTF8StringEncoding];
        [zip addDataToZip:data  date:[NSDate date] newname:@"dock.txt"];
    }
    if (info) {
        
        NSData *data = [info dataUsingEncoding:NSUTF8StringEncoding];
        [zip addDataToZip:data  date:[NSDate date] newname:@"info.txt"];
    }
    if (skyType) {
        
        NSData *data = [skyType dataUsingEncoding:NSUTF8StringEncoding];
        [zip addDataToZip:data  date:[NSDate date] newname:@"skyType.txt"];
    }
    [zip addDataToZip:thumbData    date:[NSDate date] newname:@"thumb.png"];
    [zip addDataToZip:universeData date:[NSDate date] newname:@"universe.univ"];
    [zip addDataToZip:pal1         date:[NSDate date] newname:@"pal1.pal"];
    [zip addDataToZip:pal2         date:[NSDate date] newname:@"pal2.pal"];
    [zip CloseZipFile2];
    return fullPath;
}

+ (SkyPatch*)unZipArchive:(ZipArchive*)zipArchive
                     name:(NSString*)name
             withUniverse:(bool)universe {
    
    SkyPatch *skyPatch = [SkyPatch.alloc init];
    skyPatch.name  = [name copy];
    skyPatch.thumb = [zipArchive dataFromFile:@".png" foundName:nil];
    skyPatch.pal1  = [zipArchive dataFromFile:@"pal1.pal" foundName:nil];
    skyPatch.pal2  = [zipArchive dataFromFile:@"pal2.pal" foundName:nil];
   
    NSString *shaderName = @"";
    skyPatch.shaderFsh  = [zipArchive stringFromFile:@".fsh" foundName:&shaderName];
    skyPatch.shaderVsh  = [zipArchive stringFromFile:@".vsh" foundName:&shaderName];
    skyPatch.shaderName = shaderName;
    
    NSString *fname  = [name stringByAppendingPathExtension:@"tr3"];
    skyPatch.tr3Buf  = [zipArchive stringFromFile:fname foundName:nil];
    skyPatch.dock    = [zipArchive stringFromFile:@"dock.txt" foundName:nil];
    skyPatch.skyType = [zipArchive stringFromFile:@"type.txt" foundName:nil];
    
    if (universe) {
        skyPatch.universe = [zipArchive dataFromFile:@"universe.univ" foundName:nil];
    }
    return skyPatch;
}

+ (SkyPatch*)unzipName:(NSString*)name path:(NSString*)path withUniverse:(bool)universe {
    
    ZipArchive *zipArchive = [ZipArchive.alloc init];	
    SkyPatch *skyPatch = nil; 
    
    if ([zipArchive UnzipOpenFile:path]) {
    
        skyPatch = [SkyPatch.alloc init];
        skyPatch = [SkyPatch unZipArchive:zipArchive name:name withUniverse:universe];
        skyPatch.name = name;
        [zipArchive UnzipCloseFile];
    }
    return skyPatch;
}

/* read zip file that has a ".muse" extension and read itscontents
 * name: filename with optional ".muse" extension
 * withUniverse: replace current cell universe with one in .muse file
 */
+ (SkyPatch*)readPatchName:(NSString*)name withUniverse:(bool)universe {
    
    NSString *nomuse  = [name stringByReplacingOccurrencesOfString:@".muse" withString:@""];
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSString *nameMuse = [NSString stringWithFormat:@"%@.muse",nomuse];
    NSString *docsPath = [docsDir stringByAppendingPathComponent:nameMuse];

    return [SkyPatch unzipName:nomuse path:docsPath withUniverse:universe];
}

@end
