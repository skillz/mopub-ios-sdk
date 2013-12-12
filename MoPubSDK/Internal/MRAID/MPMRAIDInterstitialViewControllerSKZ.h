//
//  MPMRAIDInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialViewControllerSKZ.h"

#import "MRAdViewSKZ.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPMRAIDInterstitialViewControllerDelegate;
@class MPAdConfigurationSKZ;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPMRAIDInterstitialViewControllerSKZ : MPInterstitialViewControllerSKZ <MRAdViewDelegateSKZ>
{
    MRAdViewSKZ *_interstitialView;
    MPAdConfigurationSKZ *_configuration;
    BOOL _advertisementHasCustomCloseButton;
}

- (id)initWithAdConfiguration:(MPAdConfigurationSKZ *)configuration;
- (void)startLoading;

@end

