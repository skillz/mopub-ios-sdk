//
//  MPBaseInterstitialAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 4/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MPAdConfigurationSKZ, CLLocation;

@protocol MPInterstitialAdapterDelegateSKZ;

@interface MPBaseInterstitialAdapterSKZ : NSObject

@property (nonatomic, assign) id<MPInterstitialAdapterDelegateSKZ> delegate;

/*
 * Creates an adapter with a reference to an MPInterstitialAdManager.
 */
- (id)initWithDelegate:(id<MPInterstitialAdapterDelegateSKZ>)delegate;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

- (void)getAdWithConfiguration:(MPAdConfigurationSKZ *)configuration;
- (void)_getAdWithConfiguration:(MPAdConfigurationSKZ *)configuration;

- (void)didStopLoading;

/*
 * Presents the interstitial from the specified view controller.
 */
- (void)showInterstitialFromViewController:(UIViewController *)controller;

@end

@interface MPBaseInterstitialAdapterSKZ (ProtectedMethods)

- (void)trackImpression;
- (void)trackClick;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@class MPInterstitialAdControllerSKZ;

@protocol MPInterstitialAdapterDelegateSKZ

- (MPInterstitialAdControllerSKZ *)interstitialAdController;
- (id)interstitialDelegate;
- (CLLocation *)location;

- (void)adapterDidFinishLoadingAd:(MPBaseInterstitialAdapterSKZ *)adapter;
- (void)adapter:(MPBaseInterstitialAdapterSKZ *)adapter didFailToLoadAdWithError:(NSError *)error;
- (void)interstitialWillAppearForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter;
- (void)interstitialDidAppearForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter;
- (void)interstitialWillDisappearForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter;
- (void)interstitialDidDisappearForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter;
- (void)interstitialDidExpireForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter;
- (void)interstitialWillLeaveApplicationForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter;

@end
