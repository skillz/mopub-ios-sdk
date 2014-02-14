//
//  MPMRAIDBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerCustomEventSKZ.h"
#import "MRAdViewSKZ.h"
#import "MPPrivateBannerCustomEventDelegate.h"

@interface MPMRAIDBannerCustomEventSKZ : MPBannerCustomEventSKZ <MRAdViewDelegateSKZ>

@property (nonatomic, weak) id<MPPrivateBannerCustomEventDelegateSKZ> delegate;

@end
