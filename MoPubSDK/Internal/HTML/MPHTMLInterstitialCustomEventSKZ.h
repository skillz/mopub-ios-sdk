//
//  MPHTMLInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEventSKZ.h"
#import "MPHTMLInterstitialViewControllerSKZ.h"
#import "MPPrivateInterstitialCustomEventDelegate.h"

@interface MPHTMLInterstitialCustomEventSKZ : MPInterstitialCustomEventSKZ <MPInterstitialViewControllerDelegateSKZ>

@property (nonatomic, weak) id<MPPrivateInterstitialCustomEventDelegateSKZ> delegate;

@end
