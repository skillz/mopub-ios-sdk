//
//  MPPrivateBannerCustomEventDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPBannerCustomEventDelegate.h"

@class MPAdConfigurationSKZ;

@protocol MPPrivateBannerCustomEventDelegateSKZ <MPBannerCustomEventDelegateSKZ>

- (NSString *)adUnitId;
- (MPAdConfigurationSKZ *)configuration;
- (id)bannerDelegate;

@end
