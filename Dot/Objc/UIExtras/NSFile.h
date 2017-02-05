#import "main.h"

@interface NSFile: NSObject

+ (NSString*)readFilename:(NSString*)name ofType:(NSString*)type;
+ (const char *)readPath:(NSString*)path name:(NSString*)name ext:(NSString*)ext;
+ (void) copyDir:(NSString*)dirName;

@end
