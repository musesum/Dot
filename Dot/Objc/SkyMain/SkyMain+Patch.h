#import "SkyMain.h"
#import "SkyPatch.h"

@class SHKItem;

@interface SkyMain (Patch)

- (void)parsePatch:(SkyPatch*)patch;
- (void)setPatchNow:(SkyPatch*)patch;
- (bool)parsePalFromPatch:(SkyPatch*)patch;

- (NSData*)getSkyUniverse;
- (NSData*)getSkyPal:(int)index;
- (NSString*)getDock;

- (void)saveSystemPlacemark;
- (NSString*)saveImage:(UIImage*)image;

- (void)readImageFromType:(ImageFromType)type_;
- (NSString*)filenameFromImageType:(ImageFromType)type_;
- (void)readLastImage;
- (void)writeLastImageFromType;
- (void)writeData:(NSData*)data imageFrom:(ImageFromType)imageFrom_;
- (void)advanceWithImage:(UIImage*)image rect:(CGRect)sourceRect imageType:(ImageFromType)imageFrom_;
@end
