//
//  MPMRAIDInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPMRAIDInterstitialCustomEventSKZ.h"
#import "MPInstanceProviderSKZ.h"
#import "MPLogging.h"

@interface MPMRAIDInterstitialCustomEventSKZ ()

@property (nonatomic, retain) MPMRAIDInterstitialViewControllerSKZ *interstitial;

@end

@implementation MPMRAIDInterstitialCustomEventSKZ

@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Loading MoPub MRAID interstitial");
    self.interstitial = [[MPInstanceProviderSKZ sharedProvider] buildMPMRAIDInterstitialViewControllerWithDelegate:self
                                                                                                  configuration:[self.delegate configuration]];
    [self.interstitial setCloseButtonStyle:MPInterstitialCloseButtonStyleAdControlled];
    [self.interstitial startLoading];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
    self.interstitial = nil;

    [super dealloc];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller
{
    [self.interstitial presentInterstitialFromViewController:controller];
}

#pragma mark - MPMRAIDInterstitialViewControllerDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (void)interstitialDidLoadAd:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub MRAID interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub MRAID interstitial did fail");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub MRAID interstitial will appear");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidAppear:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub MRAID interstitial did appear");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDisappear:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub MRAID interstitial will disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDisappear:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub MRAID interstitial did disappear");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub MRAID interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
