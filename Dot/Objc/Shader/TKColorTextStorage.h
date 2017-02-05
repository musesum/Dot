#import "main.h"
#define TKDDefaultTokenName  @"TKDDefaultTokenName"

@interface TKColorTextStorage : NSTextStorage

@property (nonatomic, strong) NSMutableDictionary *tokens; // a dictionary, keyed by text snippets, with attributes we want to add

@end
