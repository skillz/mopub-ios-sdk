//
//  MPHTMLInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPHTMLInterstitialCustomEventSKZ.h"
#import "MPLogging.h"
#import "MPAdConfigurationSKZ.h"
#import "MPInstanceProviderSKZ.h"

@interface MPHTMLInterstitialCustomEventSKZ ()

@property (nonatomic, strong) MPHTMLInterstitialViewControllerSKZ *interstitial;

@end

@implementation MPHTMLInterstitialCustomEventSKZ

@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Loading MoPub HTML interstitial");
    MPAdConfigurationSKZ *configuration = [self.delegate configuration];
    MPLogTrace(@"Loading HTML interstitial with source: %@", [configuration adResponseHTMLString]);

    self.interstitial = [[MPInstanceProviderSKZ sharedProvider] buildMPHTMLInterstitialViewControllerWithDelegate:self
                                                                                               orientationType:configuration.orientationType
                                                                                          customMethodDelegate:[self.delegate interstitialDelegate]];
    [self.interstitial loadConfiguration:configuration];
}

- (void)dealloc
{
    [self.interstitial setDelegate:nil];
    [self.interstitial setCustomMethodDelegate:nil];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentInterstitialFromViewController:rootViewController];
}

- (void)dismissInterstitialAnimated:(BOOL)animated
{
    [self.interstitial dismissInterstitialAnimated:animated];
}

#pragma mark - MPInterstitialViewControllerDelegate

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
    MPLogInfo(@"MoPub HTML interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub HTML interstitial did fail");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub HTML interstitial will appear");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidAppear:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub HTML interstitial did appear");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDisappear:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub HTML interstitial will disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDisappear:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub HTML interstitial did disappear");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(MPInterstitialViewControllerSKZ *)interstitial
{
    MPLogInfo(@"MoPub HTML interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
