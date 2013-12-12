//
//  MPInterstitialAdManagerDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPInterstitialAdManagerSKZ;
@class MPInterstitialAdControllerSKZ;
@class CLLocation;

@protocol MPInterstitialAdManagerDelegateSKZ <NSObject>

- (MPInterstitialAdControllerSKZ *)interstitialAdController;
- (CLLocation *)location;
- (id)interstitialDelegate;
- (void)managerDidLoadInterstitial:(MPInterstitialAdManagerSKZ *)manager;
- (void)manager:(MPInterstitialAdManagerSKZ *)manager
didFailToLoadInterstitialWithError:(NSError *)error;
- (void)managerWillPresentInterstitial:(MPInterstitialAdManagerSKZ *)manager;
- (void)managerDidPresentInterstitial:(MPInterstitialAdManagerSKZ *)manager;
- (void)managerWillDismissInterstitial:(MPInterstitialAdManagerSKZ *)manager;
- (void)managerDidDismissInterstitial:(MPInterstitialAdManagerSKZ *)manager;
- (void)managerDidExpireInterstitial:(MPInterstitialAdManagerSKZ *)manager;

@end
