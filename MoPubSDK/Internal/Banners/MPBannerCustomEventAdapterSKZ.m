//
//  MPBannerCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBannerCustomEventAdapterSKZ.h"

#import "MPAdConfigurationSKZ.h"
#import "MPBannerCustomEventSKZ.h"
#import "MPInstanceProviderSKZ.h"
#import "MPLogging.h"

@interface MPBannerCustomEventAdapterSKZ ()

@property (nonatomic, strong) MPBannerCustomEventSKZ *bannerCustomEvent;
@property (nonatomic, strong) MPAdConfigurationSKZ *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

- (void)trackClickOnce;

@end

@implementation MPBannerCustomEventAdapterSKZ
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

- (void)unregisterDelegate
{
    if ([self.bannerCustomEvent respondsToSelector:@selector(invalidate)]) {
        // Secret API to allow us to detach the custom event from (shared instance) routers synchronously
        // See the iAd banner custom event for an example use case.
        [self.bannerCustomEvent performSelector:@selector(invalidate)];
    }
    self.bannerCustomEvent.delegate = nil;
    self.bannerCustomEvent = nil;

    [super unregisterDelegate];
}


////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getAdWithConfiguration:(MPAdConfigurationSKZ *)configuration containerSize:(CGSize)size
{
    MPLogInfo(@"Looking for custom event class named %@.", configuration.customEventClass);
    self.configuration = configuration;

    self.bannerCustomEvent = [[MPInstanceProviderSKZ sharedProvider] buildBannerCustomEventFromCustomClass:configuration.customEventClass
                                                                                               delegate:self];
    if (self.bannerCustomEvent) {
        [self.bannerCustomEvent requestAdWithSize:size customEventInfo:configuration.customEventClassData];
    } else {
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.bannerCustomEvent rotateToOrientation:newOrientation];
}

- (void)didDisplayAd
{
    if ([self.bannerCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedImpression) {
        self.hasTrackedImpression = YES;
        [self trackImpression];
    }

    [self.bannerCustomEvent didDisplayAd];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - MPPrivateBannerCustomEventDelegate

- (NSString *)adUnitId
{
    return [self.delegate banner].adUnitId;
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (id)bannerDelegate
{
    return [self.delegate bannerDelegate];
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (void)bannerCustomEvent:(MPBannerCustomEventSKZ *)event didLoadAd:(UIView *)ad
{
    [self didStopLoading];
    if (ad) {
        [self.delegate adapter:self didFinishLoadingAd:ad];
    } else {
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)bannerCustomEvent:(MPBannerCustomEventSKZ *)event didFailToLoadAdWithError:(NSError *)error
{
    [self didStopLoading];
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)bannerCustomEventWillBeginAction:(MPBannerCustomEventSKZ *)event
{
    [self trackClickOnce];
    [self.delegate userActionWillBeginForAdapter:self];
}

- (void)bannerCustomEventDidFinishAction:(MPBannerCustomEventSKZ *)event
{
    [self.delegate userActionDidFinishForAdapter:self];
}

- (void)bannerCustomEventWillLeaveApplication:(MPBannerCustomEventSKZ *)event
{
    [self trackClickOnce];
    [self.delegate userWillLeaveApplicationFromAdapter:self];
}

- (void)trackClickOnce
{
    if ([self.bannerCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedClick) {
        self.hasTrackedClick = YES;
        [self trackClick];
    }
}

@end
