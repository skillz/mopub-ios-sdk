//
//  MPInterstitialAdManager.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "MPInterstitialAdManagerSKZ.h"

#import "MPAdServerURLBuilderSKZ.h"
#import "MPInterstitialAdControllerSKZ.h"
#import "MPInterstitialCustomEventAdapterSKZ.h"
#import "MPInstanceProviderSKZ.h"
#import "MPInterstitialAdManagerDelegate.h"
#import "MPLogging.h"

@interface MPInterstitialAdManagerSKZ ()

@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign, readwrite) BOOL ready;
@property (nonatomic, retain) MPBaseInterstitialAdapterSKZ *adapter;
@property (nonatomic, retain) MPAdServerCommunicatorSKZ *communicator;
@property (nonatomic, retain) MPAdConfigurationSKZ *configuration;

- (void)setUpAdapterWithConfiguration:(MPAdConfigurationSKZ *)configuration;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPInterstitialAdManagerSKZ

@synthesize loading = _loading;
@synthesize ready = _ready;
@synthesize delegate = _delegate;
@synthesize communicator = _communicator;
@synthesize adapter = _adapter;
@synthesize configuration = _configuration;

- (id)initWithDelegate:(id<MPInterstitialAdManagerDelegateSKZ>)delegate
{
    self = [super init];
    if (self) {
        self.communicator = [[MPInstanceProviderSKZ sharedProvider] buildMPAdServerCommunicatorWithDelegate:self];
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self.communicator cancel];
    [self.communicator setDelegate:nil];
    self.communicator = nil;

    self.adapter = nil;

    self.configuration = nil;

    [super dealloc];
}

- (void)setAdapter:(MPBaseInterstitialAdapterSKZ *)adapter
{
    if (self.adapter != adapter) {
        [self.adapter unregisterDelegate];
        [_adapter release];
        _adapter = [adapter retain];
    }
}

#pragma mark - Public

- (void)loadAdWithURL:(NSURL *)URL
{
    if (self.loading) {
        MPLogWarn(@"Interstitial controller is already loading an ad. "
                  @"Wait for previous load to finish.");
        return;
    }

    MPLogInfo(@"Interstitial controller is loading ad with MoPub server URL: %@", URL);

    self.loading = YES;
    [self.communicator loadURL:URL];
}


- (void)loadInterstitialWithAdUnitID:(NSString *)ID keywords:(NSString *)keywords location:(CLLocation *)location testing:(BOOL)testing
{
    if (self.ready) {
        [self.delegate managerDidLoadInterstitial:self];
    } else {
        [self loadAdWithURL:[MPAdServerURLBuilderSKZ URLWithAdUnitID:ID
                                                         keywords:keywords
                                                         location:location
                                                          testing:testing]];
    }
}

- (void)presentInterstitialFromViewController:(UIViewController *)controller
{
    if (self.ready) {
        [self.adapter showInterstitialFromViewController:controller];
    }
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (MPInterstitialAdControllerSKZ *)interstitialAdController
{
    return [self.delegate interstitialAdController];
}

- (id)interstitialDelegate
{
    return [self.delegate interstitialDelegate];
}

#pragma mark - MPAdServerCommunicatorDelegate

- (void)communicatorDidReceiveAdConfiguration:(MPAdConfigurationSKZ *)configuration
{
    self.configuration = configuration;

    MPLogInfo(@"Interstatial ad view is fetching ad network type: %@", self.configuration.networkType);

    if ([self.configuration.networkType isEqualToString:@"clear"]) {
        MPLogInfo(@"Ad server response indicated no ad available.");
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:nil];
        return;
    }

    if (self.configuration.adType != MPAdTypeInterstitial) {
        MPLogWarn(@"Could not load ad: interstitial object received a non-interstitial ad unit ID.");
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:nil];
        return;
    }

    [self setUpAdapterWithConfiguration:self.configuration];
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;

    [self.delegate manager:self didFailToLoadInterstitialWithError:error];
}

- (void)setUpAdapterWithConfiguration:(MPAdConfigurationSKZ *)configuration;
{
    MPBaseInterstitialAdapterSKZ *adapter = [[MPInstanceProviderSKZ sharedProvider] buildInterstitialAdapterForConfiguration:configuration
                                                                                                              delegate:self];
    if (!adapter) {
        [self adapter:nil didFailToLoadAdWithError:nil];
        return;
    }

    self.adapter = adapter;
    [self.adapter _getAdWithConfiguration:configuration];
}

#pragma mark - MPInterstitialAdapterDelegate

- (void)adapterDidFinishLoadingAd:(MPBaseInterstitialAdapterSKZ *)adapter
{
    self.ready = YES;
    self.loading = NO;
    [self.delegate managerDidLoadInterstitial:self];
}

- (void)adapter:(MPBaseInterstitialAdapterSKZ *)adapter didFailToLoadAdWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;
    [self loadAdWithURL:self.configuration.failoverURL];
}

- (void)interstitialWillAppearForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter
{
    [self.delegate managerWillPresentInterstitial:self];
}

- (void)interstitialDidAppearForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter
{
    [self.delegate managerDidPresentInterstitial:self];
}

- (void)interstitialWillDisappearForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter
{
    [self.delegate managerWillDismissInterstitial:self];
}

- (void)interstitialDidDisappearForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter
{
    self.ready = NO;
    [self.delegate managerDidDismissInterstitial:self];
}

- (void)interstitialDidExpireForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter
{
    self.ready = NO;
    [self.delegate managerDidExpireInterstitial:self];
}

- (void)interstitialWillLeaveApplicationForAdapter:(MPBaseInterstitialAdapterSKZ *)adapter
{
    // TODO: Signal to delegate.
}

#pragma mark - Legacy Custom Events

- (void)customEventDidLoadAd
{
    // XXX: The deprecated custom event behavior is to report an impression as soon as an ad loads,
    // rather than when the ad is actually displayed. Because of this, you may see impression-
    // reporting discrepancies between MoPub and your custom ad networks.
    if ([self.adapter respondsToSelector:@selector(customEventDidLoadAd)]) {
        self.loading = NO;
        [self.adapter performSelector:@selector(customEventDidLoadAd)];
    }
}

- (void)customEventDidFailToLoadAd
{
    if ([self.adapter respondsToSelector:@selector(customEventDidFailToLoadAd)]) {
        self.loading = NO;
        [self.adapter performSelector:@selector(customEventDidFailToLoadAd)];
    }
}

- (void)customEventActionWillBegin
{
    if ([self.adapter respondsToSelector:@selector(customEventActionWillBegin)]) {
        [self.adapter performSelector:@selector(customEventActionWillBegin)];
    }
}

@end
