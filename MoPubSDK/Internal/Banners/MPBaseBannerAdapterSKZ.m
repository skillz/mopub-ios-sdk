//
//  MPBaseBannerAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPBaseBannerAdapterSKZ.h"
#import "MPConstants.h"

#import "MPAdConfigurationSKZ.h"
#import "MPLogging.h"
#import "MPInstanceProviderSKZ.h"
#import "MPAnalyticsTrackerSKZ.h"
#import "MPTimerSKZ.h"

@interface MPBaseBannerAdapterSKZ ()

@property (nonatomic, strong) MPAdConfigurationSKZ *configuration;
@property (nonatomic, strong) MPTimerSKZ *timeoutTimer;

- (void)startTimeoutTimer;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPBaseBannerAdapterSKZ

@synthesize delegate = _delegate;
@synthesize configuration = _configuration;
@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithDelegate:(id<MPBannerAdapterDelegateSKZ>)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self unregisterDelegate];

    [self.timeoutTimer invalidate];

}

- (void)unregisterDelegate
{
    self.delegate = nil;
}

#pragma mark - Requesting Ads

- (void)getAdWithConfiguration:(MPAdConfigurationSKZ *)configuration containerSize:(CGSize)size
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(MPAdConfigurationSKZ *)configuration containerSize:(CGSize)size
{
    self.configuration = configuration;

    [self startTimeoutTimer];

    [self getAdWithConfiguration:configuration containerSize:size];
}

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)didDisplayAd
{
    [self trackImpression];
}

- (void)startTimeoutTimer
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
    self.configuration.adTimeoutInterval : BANNER_TIMEOUT_INTERVAL;

    if (timeInterval > 0) {
        self.timeoutTimer = [[MPInstanceProviderSKZ sharedProvider] buildMPTimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(timeout)
                                                                                      repeats:NO];

        [self.timeoutTimer scheduleNow];
    }
}

- (void)timeout
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

#pragma mark - Rotation

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    // Do nothing by default. Subclasses can override.
    MPLogDebug(@"rotateToOrientation %d called for adapter %@ (%p)",
          newOrientation, NSStringFromClass([self class]), self);
}

#pragma mark - Metrics

- (void)trackImpression
{
    [[[MPInstanceProviderSKZ sharedProvider] sharedMPAnalyticsTracker] trackImpressionForConfiguration:self.configuration];
}

- (void)trackClick
{
    [[[MPInstanceProviderSKZ sharedProvider] sharedMPAnalyticsTracker] trackClickForConfiguration:self.configuration];
}

@end
