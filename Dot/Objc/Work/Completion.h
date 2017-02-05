
#import "main.h"

typedef void (^CompletionVoid)();
typedef void (^CompletionFloat)(CGFloat value);
typedef void (^CompletionPoint)(CGPoint value);
typedef void (^CompletionPointFloat)(CGPoint value, CGFloat progress);
typedef void (^CompletionFloat2)(CGFloat value, CGFloat progress);
typedef void (^CompletionDict)(NSDictionary *d);
