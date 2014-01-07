//
//  MPInterstitialCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialCustomEventAdapterSKZ.h"

#import "MPAdConfigurationSKZ.h"
#import "MPLogging.h"
#import "MPInstanceProviderSKZ.h"
#import "MPInterstitialCustomEventSKZ.h"
#import "MPInterstitialAdControllerSKZ.h"

@interface MPInterstitialCustomEventAdapterSKZ ()

@property (nonatomic, retain) MPInterstitialCustomEventSKZ *interstitialCustomEvent;
@property (nonatomic, retain) MPAdConfigurationSKZ *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

@end

@implementation MPInterstitialCustomEventAdapterSKZ
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

@synthesize interstitialCustomEvent = _interstitialCustomEvent;

- (void)dealloc
{
    if ([self.interstitialCustomEvent respondsToSelector:@selector(invalidate)]) {
        // Secret API to allow us to detach the custom event from (shared instance) routers synchronously
        // See the chartboost interstitial custom event for an example use case.
        [self.interstitialCustomEvent performSelector:@selector(invalidate)];
    }
    self.interstitialCustomEvent.delegate = nil;
    [[_interstitialCustomEvent retain] autorelease];
    self.interstitialCustomEvent = nil;
    self.configuration = nil;

    [super dealloc];
}

- (void)getAdWithConfiguration:(MPAdConfigurationSKZ *)configuration
{
    MPLogInfo(@"Looking for custom event class named %@.", configuration.customEventClass);
    self.configuration = configuration;

    self.interstitialCustomEvent = [[MPInstanceProviderSKZ sharedProvider] buildInterstitialCustomEventFromCustomClass:configuration.customEventClass delegate:self];

    if (self.interstitialCustomEvent) {
        [self.interstitialCustomEvent requestInterstitialWithCustomEventInfo:configuration.customEventClassData];
    } else {
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [self.interstitialCustomEvent showInterstitialFromRootViewController:controller];
}

- (void)dismissInterstitialAnimated:(BOOL)animated
{
    [self.interstitialCustomEvent dismissInterstitialAnimated:animated];
}

#pragma mark - MPInterstitialCustomEventDelegate

- (NSString *)adUnitId
{
    return [self.delegate interstitialAdController].adUnitId;
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (id)interstitialDelegate
{
    return [self.delegate interstitialDelegate];
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEventSKZ *)customEvent
                      didLoadAd:(id)ad
{
    [self didStopLoading];
    [self.delegate adapterDidFinishLoadingAd:self];
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEventSKZ *)customEvent
       didFailToLoadAdWithError:(NSError *)error
{
    [self didStopLoading];
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialCustomEventWillAppear:(MPInterstitialCustomEventSKZ *)customEvent
{
    [self.delegate interstitialWillAppearForAdapter:self];
}

- (void)interstitialCustomEventDidAppear:(MPInterstitialCustomEventSKZ *)customEvent
{
    if ([self.interstitialCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedImpression) {
        self.hasTrackedImpression = YES;
        [self trackImpression];
    }
    [self.delegate interstitialDidAppearForAdapter:self];
}

- (void)interstitialCustomEventWillDisappear:(MPInterstitialCustomEventSKZ *)customEvent
{
    [self.delegate interstitialWillDisappearForAdapter:self];
}

- (void)interstitialCustomEventDidDisappear:(MPInterstitialCustomEventSKZ *)customEvent
{
    [self.delegate interstitialDidDisappearForAdapter:self];
}

- (void)interstitialCustomEventDidExpire:(MPInterstitialCustomEventSKZ *)customEvent
{
    [self.delegate interstitialDidExpireForAdapter:self];
}

- (void)interstitialCustomEventDidReceiveTapEvent:(MPInterstitialCustomEventSKZ *)customEvent
{
    if ([self.interstitialCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedClick) {
        self.hasTrackedClick = YES;
        [self trackClick];
    }
}

- (void)interstitialCustomEventWillLeaveApplication:(MPInterstitialCustomEventSKZ *)customEvent
{
    [self.delegate interstitialWillLeaveApplicationForAdapter:self];
}

@end
