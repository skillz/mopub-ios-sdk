//
//  MPMRAIDInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEventSKZ.h"
#import "MPMRAIDInterstitialViewControllerSKZ.h"
#import "MPPrivateInterstitialCustomEventDelegate.h"

@interface MPMRAIDInterstitialCustomEventSKZ : MPInterstitialCustomEventSKZ <MPInterstitialViewControllerDelegateSKZ>

@property (nonatomic, assign) id<MPPrivateInterstitialCustomEventDelegateSKZ> delegate;

@end
