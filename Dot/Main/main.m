#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSString* className = NSStringFromClass([AppDelegate class]);
        return UIApplicationMain(argc, argv, nil, className);
    }
}
