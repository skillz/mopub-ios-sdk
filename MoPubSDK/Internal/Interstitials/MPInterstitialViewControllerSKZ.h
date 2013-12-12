//
//  MPInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGlobal.h"

@class CLLocation;

@protocol MPInterstitialViewControllerDelegateSKZ;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPInterstitialViewControllerSKZ : UIViewController

@property (nonatomic, assign) MPInterstitialCloseButtonStyle closeButtonStyle;
@property (nonatomic, assign) MPInterstitialOrientationType orientationType;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, assign) id<MPInterstitialViewControllerDelegateSKZ> delegate;

- (void)presentInterstitialFromViewController:(UIViewController *)controller;
- (void)dismissInterstitialAnimated:(BOOL)animated;
- (BOOL)shouldDisplayCloseButton;
- (void)willPresentInterstitial;
- (void)didPresentInterstitial;
- (void)willDismissInterstitial;
- (void)didDismissInterstitial;
- (void)layoutCloseButton;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPInterstitialViewControllerDelegateSKZ <NSObject>

- (NSString *)adUnitId;
- (CLLocation *)location;
- (void)interstitialDidLoadAd:(MPInterstitialViewControllerSKZ *)interstitial;
- (void)interstitialDidFailToLoadAd:(MPInterstitialViewControllerSKZ *)interstitial;
- (void)interstitialWillAppear:(MPInterstitialViewControllerSKZ *)interstitial;
- (void)interstitialDidAppear:(MPInterstitialViewControllerSKZ *)interstitial;
- (void)interstitialWillDisappear:(MPInterstitialViewControllerSKZ *)interstitial;
- (void)interstitialDidDisappear:(MPInterstitialViewControllerSKZ *)interstitial;
- (void)interstitialWillLeaveApplication:(MPInterstitialViewControllerSKZ *)interstitial;

@end
