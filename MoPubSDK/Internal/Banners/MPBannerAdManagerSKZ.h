//
//  MPBannerAdManager.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdServerCommunicatorSKZ.h"
#import "MPBaseBannerAdapterSKZ.h"

@protocol MPBannerAdManagerDelegateSKZ;

@interface MPBannerAdManagerSKZ : NSObject <MPAdServerCommunicatorDelegateSKZ, MPBannerAdapterDelegateSKZ>

@property (nonatomic, assign) id<MPBannerAdManagerDelegateSKZ> delegate;

- (id)initWithDelegate:(id<MPBannerAdManagerDelegateSKZ>)delegate;

- (void)loadAd;
- (void)forceRefreshAd;
- (void)stopAutomaticallyRefreshingContents;
- (void)startAutomaticallyRefreshingContents;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

// Deprecated.
- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;
- (void)customEventActionDidEnd;

@end
