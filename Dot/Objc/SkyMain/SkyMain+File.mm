#import "NSFile.h" // extra
#import "SkyMain+File.h"

@implementation SkyMain(File)


- (void)alertFirstTimeStartup {
    
    return; //!!
    
    NSString* message = @"Some Pyr effects may flash.\n\n";
    
    UIAlertView* alertView = [UIAlertView.alloc initWithTitle:@"WARNING!"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (void)seedFirstTimeStartup {
    
    [NSFile copyDir:@"tr3"];
    return;
    
    NSString* documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSError*  error = nil;
    NSFileManager* fileManager = [NSFileManager.alloc init];
    
    NSArray* files = [fileManager contentsOfDirectoryAtPath:documentsPath error:&error];
    if (error) {
        [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    [fileManager contentsOfDirectoryAtPath:documentsPath error:&error];
    if (error) {
        [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    bool hasPlacemark = NO;
    bool hasVersionFile = NO;
    
    for (NSString*file in files) {
        
        if ([file hasSuffix:@".version"]){
            hasVersionFile = YES;
            continue;
        }
        if (![file hasSuffix:@".muse"]){
            continue;
        }
        if ([file hasSuffix:@"Placemark.muse"])  {
            hasPlacemark = YES;
            continue;
        }
    }
    NSString* resourcePath = NSBundle.mainBundle.resourcePath;
    NSArray* resourceFiles = [fileManager contentsOfDirectoryAtPath:resourcePath error:&error];
    
    NSString* sourcePath,*destPath;
    
    if (!hasVersionFile) {
        
        sourcePath = [resourcePath stringByAppendingPathComponent:@"this.version"];
        destPath   = [documentsPath stringByAppendingPathComponent:@"this.version"];
        
        if ([fileManager fileExistsAtPath:destPath])
            [fileManager removeItemAtPath:destPath error:&error];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
        
        hasPlacemark = NO;
    }
    
    if (!hasPlacemark) {
        
        [self alertFirstTimeStartup];
        
        for (NSString*file in resourceFiles) {
            
            if (![file hasSuffix:@".muse"] &&
                ![file hasSuffix:@".html"]) {
                
                continue;
            }
            sourcePath = [resourcePath stringByAppendingPathComponent:file];
            destPath   = [documentsPath stringByAppendingPathComponent:file];
            
            if ([fileManager fileExistsAtPath:destPath]) {
                [fileManager removeItemAtPath:destPath error:&error];
            }
            [fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
        }
    }
}

@end
