//
//  MPBannerAdManagerDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAdViewSKZ;

@protocol MPAdViewDelegateSKZ;

@protocol MPBannerAdManagerDelegateSKZ <NSObject>

- (NSString *)adUnitId;
- (MPNativeAdOrientation)allowedNativeAdsOrientation;
- (MPAdViewSKZ *)banner;
- (id<MPAdViewDelegateSKZ>)bannerDelegate;
- (CGSize)containerSize;
- (BOOL)ignoresAutorefresh;
- (NSString *)keywords;
- (CLLocation *)location;
- (BOOL)isTesting;
- (UIViewController *)viewControllerForPresentingModalView;

- (void)invalidateContentView;

- (void)managerDidLoadAd:(UIView *)ad;
- (void)managerDidFailToLoadAd;
- (void)userActionWillBegin;
- (void)userActionDidFinish;
- (void)userWillLeaveApplication;

@end
