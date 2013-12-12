//
//  MRBundleManager.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRBundleManagerSKZ.h"

@implementation MRBundleManagerSKZ

static MRBundleManagerSKZ *sharedManager = nil;

+ (MRBundleManagerSKZ *)sharedManager
{
    if (!sharedManager) {
        sharedManager = [[MRBundleManagerSKZ alloc] init];
    }
    return sharedManager;
}

- (NSString *)mraidPath
{
    NSString *mraidBundlePath = [[NSBundle mainBundle] pathForResource:@"MRAID" ofType:@"bundle"];
    NSBundle *mraidBundle = [NSBundle bundleWithPath:mraidBundlePath];
    return [mraidBundle pathForResource:@"mraid" ofType:@"js"];
}

@end

