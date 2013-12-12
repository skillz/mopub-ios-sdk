//
//  MPHTMLInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPAdWebViewAgentSKZ.h"
#import "MPInterstitialViewControllerSKZ.h"

@class MPAdConfigurationSKZ;

@interface MPHTMLInterstitialViewControllerSKZ : MPInterstitialViewControllerSKZ <MPAdWebViewAgentDelegateSKZ>

@property (nonatomic, retain) MPAdWebViewAgentSKZ *backingViewAgent;
@property (nonatomic, assign) id customMethodDelegate;

- (void)loadConfiguration:(MPAdConfigurationSKZ *)configuration;

@end
