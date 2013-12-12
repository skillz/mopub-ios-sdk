//
//  MPPrivateInterstitialcustomEventDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPInterstitialCustomEventDelegate.h"

@class MPAdConfigurationSKZ;
@class CLLocation;

@protocol MPPrivateInterstitialCustomEventDelegateSKZ <MPInterstitialCustomEventDelegateSKZ>

- (NSString *)adUnitId;
- (MPAdConfigurationSKZ *)configuration;
- (id)interstitialDelegate;

@end
