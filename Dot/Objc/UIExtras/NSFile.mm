#import "NSFile.h"

@implementation NSFile

/* Read a file from either bundle or Documents directory.
 * Usually a new bundle will overwrite the Documents version,
 * Unfortunately, when the user tries the modify a Tr3 file,
 * by pulling it out of the Documents direction in iTunes,
 * editing it, and the copying the changed file back into
 * the Documents directory, the CreationDate and ModifiedDate
 * are the same. So, no way to automatically backup modified
 * files. Thus, we overwrite. Need to caution user that
 * updates to app will overwrite.
 *
 */
+ (NSString*)readFilename:(NSString*)name ofType:(NSString*)type {
    
    NSString *filename = [name stringByAppendingPathExtension:type];
    
    NSFileManager *fileManager = [NSFileManager.alloc init];
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *docPath = [docDir stringByAppendingPathComponent:filename];
    NSString *bunPath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    
    NSError *error;
    NSDictionary *bunDict = [fileManager attributesOfItemAtPath:bunPath error:&error];
    NSDate *bunModified = [bunDict objectForKey:NSFileModificationDate];
    
    // first time? copy bundle into Documents
    if (![fileManager fileExistsAtPath:docPath]) {
        
        [fileManager copyItemAtPath:bunPath toPath:docPath error:&error];
    }
    // file already exists in Documents directory
    else {
        
        NSDictionary *docDict = [fileManager attributesOfItemAtPath:docPath error:&error];
        NSDate *docModified = [docDict objectForKey:NSFileModificationDate];
        NSDate *docCreated  = [docDict objectForKey:NSFileCreationDate];
        
        // bundle is newer - installed a new version?
        if ([bunModified compare:docModified]==NSOrderedDescending) {
            
            [fileManager removeItemAtPath:docPath error:&error];
            [fileManager copyItemAtPath:bunPath toPath:docPath error:&error];
        }
    }
    return [NSString.alloc initWithContentsOfFile:docPath];
}

+ (void) copyDir:(NSString*)dirName {

    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dirName];  //folder contain images in your bundle
    NSString *destPath = [documentsDirectory stringByAppendingPathComponent:dirName];  //images is your folder under document directory
    
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destPath error:&error];  //copy every files from sourcePath to destPath
}


+ (const char *)readPath:(NSString*)path name:(NSString*)name ext:(NSString*)ext {

    NSString* pathName = [NSString stringWithFormat:@"%@/%@",path,name];
    const char* buf = [self readFilename:pathName ofType:ext].UTF8String;
    return buf;
}

@end

