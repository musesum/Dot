
#import <Availability.h>

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#endif

#if ! defined(__GNUC__)
#warning DEBUG/NDEBUG macros may not be #defined correctly
#endif
#if ! defined(DEBUG) && ! defined(NDEBUG)
#if defined(__OPTIMIZE__)
#define NDEBUG 1
#else
#define DEBUG 1
#endif
#endif

#if ! defined(DEBUG) && ! defined(NDEBUG)
#warning Neither of DEBUG/NDEBUG macros are #defined
#endif

#ifdef DEBUG
#define DebugLog(s, ...) NSLog(s, ##__VA_ARGS__)
#define DebugPrint(...) fprintf(stderr, __VA_ARGS__)
#define Debug(...) __VA_ARGS__
#else
#define DebugLog(s, ...)
#define DebugPrint(...) 
#define Debug(...) 
#endif
