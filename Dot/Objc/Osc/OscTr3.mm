//
//  OscTr3.m
//  PearlTr3Sky12
//
//  Created by Warren Stringer on 5/17/10.
//  Copyright 2010 Muse.com, Inc. All rights reserved.
//

#import "OscTr3.h"
#import "Tr3Osc.h"
#import "Tr3.h"
#define LogOscTr3(...) DebugLog(__VA_ARGS__)

@implementation OscTr3

+(OscTr3*) shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [self.alloc init];
    });
    return shared;
}

- (id)initWithTr3:(Tr3*)tr3 {
    
    self  = [super init];
    _tr3Osc = new Tr3Osc(tr3);
    return self;
}

- (void)go {

    _tr3Osc->OscReceiverLoop();
}

@end
