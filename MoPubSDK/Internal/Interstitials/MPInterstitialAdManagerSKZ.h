//
//  MPInterstitialAdManager.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPAdServerCommunicatorSKZ.h"
#import "MPBaseInterstitialAdapterSKZ.h"

@class CLLocation;
@protocol MPInterstitialAdManagerDelegateSKZ;

@interface MPInterstitialAdManagerSKZ : NSObject <MPAdServerCommunicatorDelegateSKZ,
    MPInterstitialAdapterDelegateSKZ>

@property (nonatomic, assign) id<MPInterstitialAdManagerDelegateSKZ> delegate;
@property (nonatomic, assign, readonly) BOOL ready;

- (id)initWithDelegate:(id<MPInterstitialAdManagerDelegateSKZ>)delegate;

- (void)loadInterstitialWithAdUnitID:(NSString *)ID
                            keywords:(NSString *)keywords
                            location:(CLLocation *)location
                             testing:(BOOL)testing;
- (void)presentInterstitialFromViewController:(UIViewController *)controller;

// Deprecated
- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;

@end
