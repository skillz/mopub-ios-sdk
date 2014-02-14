//
//  MPHTMLBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerCustomEventSKZ.h"
#import "MPAdWebViewAgentSKZ.h"
#import "MPPrivateBannerCustomEventDelegate.h"

@interface MPHTMLBannerCustomEventSKZ : MPBannerCustomEventSKZ <MPAdWebViewAgentDelegateSKZ>

@property (nonatomic, weak) id<MPPrivateBannerCustomEventDelegateSKZ> delegate;

@end
