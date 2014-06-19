//
//  MPInterstitialAdController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialAdControllerSKZ.h"

#import "MPLogging.h"
#import "MPInstanceProviderSKZ.h"
#import "MPInterstitialAdManagerSKZ.h"
#import "MPInterstitialAdManagerDelegate.h"

@interface MPInterstitialAdControllerSKZ () <MPInterstitialAdManagerDelegateSKZ>

@property (nonatomic, strong) MPInterstitialAdManagerSKZ *manager;

+ (NSMutableArray *)sharedInterstitials;
- (id)initWithAdUnitId:(NSString *)adUnitId;

@end

@implementation MPInterstitialAdControllerSKZ

- (id)initWithAdUnitId:(NSString *)adUnitId
{
    if (self = [super init]) {
        self.manager = [[MPInstanceProviderSKZ sharedProvider] buildMPInterstitialAdManagerWithDelegate:self];
        self.adUnitId = adUnitId;
    }
    return self;
}

- (void)cleanupForDealloc
{
    self.manager.delegate = nil;
    self.manager = nil;
}

- (void)dealloc
{
    self.delegate = nil;
    [self.manager setDelegate:nil];

    SKZLog(@"dealloc %@", self);
}

#pragma mark - Public

+ (MPInterstitialAdControllerSKZ *)interstitialAdControllerForAdUnitId:(NSString *)adUnitId
{
    NSMutableArray *interstitials = [[self class] sharedInterstitials];

    @synchronized(self) {
        // Find the correct ad controller based on the ad unit ID.
        MPInterstitialAdControllerSKZ *interstitial = nil;
        for (MPInterstitialAdControllerSKZ *currentInterstitial in interstitials) {
            if ([currentInterstitial.adUnitId isEqualToString:adUnitId]) {
                interstitial = currentInterstitial;
                break;
            }
        }

        // Create a new ad controller for this ad unit ID if one doesn't already exist.
        if (!interstitial) {
            interstitial = [[[self class] alloc] initWithAdUnitId:adUnitId];
            [interstitials addObject:interstitial];
        }

        return interstitial;
    }
}

- (BOOL)ready
{
    return self.manager.ready;
}

- (void)loadAd
{
    [self.manager loadInterstitialWithAdUnitID:self.adUnitId
                                      keywords:self.keywords
                                      location:self.location
                                       testing:self.testing];
}

- (void)showFromViewController:(UIViewController *)controller
{
    if (!controller) {
        MPLogWarn(@"The interstitial could not be shown: "
                  @"a nil view controller was passed to -showFromViewController:.");
        return;
    }

    [self.manager presentInterstitialFromViewController:controller];
}

- (void)dismissInterstitialAnimated:(BOOL)animated
{
    [self.manager dismissInterstitialAnimated:animated];
}

#pragma mark - Internal

+ (NSMutableArray *)sharedInterstitials
{
    static NSMutableArray *sharedInterstitials;

    @synchronized(self) {
        if (!sharedInterstitials) {
            sharedInterstitials = [NSMutableArray array];
        }
    }

    return sharedInterstitials;
}

#pragma mark - MPInterstitialAdManagerDelegate

- (MPInterstitialAdControllerSKZ *)interstitialAdController
{
    return self;
}

- (id)interstitialDelegate
{
    return self.delegate;
}

- (void)managerDidLoadInterstitial:(MPInterstitialAdManagerSKZ *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
        [self.delegate interstitialDidLoadAd:self];
    }
}

- (void)manager:(MPInterstitialAdManagerSKZ *)manager
        didFailToLoadInterstitialWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToLoadAd:)]) {
        [self.delegate interstitialDidFailToLoadAd:self];
    }
}

- (void)managerWillPresentInterstitial:(MPInterstitialAdManagerSKZ *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillAppear:)]) {
        [self.delegate interstitialWillAppear:self];
    }
}

- (void)managerDidPresentInterstitial:(MPInterstitialAdManagerSKZ *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidAppear:)]) {
        [self.delegate interstitialDidAppear:self];
    }
}

- (void)managerWillDismissInterstitial:(MPInterstitialAdManagerSKZ *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillDisappear:)]) {
        [self.delegate interstitialWillDisappear:self];
    }
}

- (void)managerDidDismissInterstitial:(MPInterstitialAdManagerSKZ *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidDisappear:)]) {
        [self.delegate interstitialDidDisappear:self];
    }
}

- (void)managerDidExpireInterstitial:(MPInterstitialAdManagerSKZ *)manager
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidExpire:)]) {
        [self.delegate interstitialDidExpire:self];
    }
}

#pragma mark - Deprecated

+ (NSMutableArray *)sharedInterstitialAdControllers
{
    return [[self class] sharedInterstitials];
}

+ (void)removeSharedInterstitialAdController:(MPInterstitialAdControllerSKZ *)controller
{
    [[[self class] sharedInterstitials] removeObject:controller];
}

- (void)customEventDidLoadAd
{
    [self.manager customEventDidLoadAd];
}

- (void)customEventDidFailToLoadAd
{
    [self.manager customEventDidFailToLoadAd];
}

- (void)customEventActionWillBegin
{
    [self.manager customEventActionWillBegin];
}

@end
