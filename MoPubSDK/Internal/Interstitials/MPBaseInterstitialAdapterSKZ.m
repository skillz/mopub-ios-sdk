//
//  MPBaseInterstitialAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 4/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "MPBaseInterstitialAdapterSKZ.h"
#import "MPAdConfigurationSKZ.h"
#import "MPGlobal.h"
#import "MPAnalyticsTrackerSKZ.h"
#import "MPInstanceProviderSKZ.h"
#import "MPTimerSKZ.h"
#import "MPConstants.h"

@interface MPBaseInterstitialAdapterSKZ ()

@property (nonatomic, strong) MPAdConfigurationSKZ *configuration;
@property (nonatomic, strong) MPTimerSKZ *timeoutTimer;

- (void)startTimeoutTimer;

@end

@implementation MPBaseInterstitialAdapterSKZ

@synthesize delegate = _delegate;
@synthesize configuration = _configuration;
@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithDelegate:(id<MPInterstitialAdapterDelegateSKZ>)delegate
{
    self = [super init];
    if (self) {
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

- (void)getAdWithConfiguration:(MPAdConfigurationSKZ *)configuration
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(MPAdConfigurationSKZ *)configuration
{
    self.configuration = configuration;

    [self startTimeoutTimer];

    [self getAdWithConfiguration:configuration];
}

- (void)startTimeoutTimer
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
            self.configuration.adTimeoutInterval : INTERSTITIAL_TIMEOUT_INTERVAL;

    if (timeInterval > 0) {
        self.timeoutTimer = [[MPInstanceProviderSKZ sharedProvider] buildMPTimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(timeout)
                                                                                      repeats:NO];

        [self.timeoutTimer scheduleNow];
    }
}

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)timeout
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

#pragma mark - Presentation

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)dismissInterstitialAnimated:(BOOL)animated
{
    [self doesNotRecognizeSelector:_cmd];
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

