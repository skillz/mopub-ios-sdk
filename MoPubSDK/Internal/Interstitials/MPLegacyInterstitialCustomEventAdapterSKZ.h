//
//  MPLegacyInterstitialCustomEventAdapter.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBaseInterstitialAdapterSKZ.h"

@interface MPLegacyInterstitialCustomEventAdapterSKZ : MPBaseInterstitialAdapterSKZ

- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;

@end
