//
//  MPMRAIDInterstitialViewController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPMRAIDInterstitialViewControllerSKZ.h"

#import "MPAdConfigurationSKZ.h"

@interface MPMRAIDInterstitialViewControllerSKZ ()

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPMRAIDInterstitialViewControllerSKZ

@synthesize delegate = _delegate;

- (id)initWithAdConfiguration:(MPAdConfigurationSKZ *)configuration
{
    self = [super init];
    if (self) {
        CGFloat width = MAX(configuration.preferredSize.width, 1);
        CGFloat height = MAX(configuration.preferredSize.height, 1);
        CGRect frame = CGRectMake(0, 0, width, height);
        _interstitialView = [[MRAdViewSKZ alloc] initWithFrame:frame
                                            allowsExpansion:NO
                                           closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                              placementType:MRAdViewPlacementTypeInterstitial];
        _interstitialView.delegate = self;
        _interstitialView.adType = configuration.precacheRequired ? MRAdViewAdTypePreCached : MRAdViewAdTypeDefault;
        _configuration = [configuration retain];
        self.orientationType = [_configuration orientationType];
        _advertisementHasCustomCloseButton = NO;
    }
    return self;
}

- (void)dealloc
{
    _interstitialView.delegate = nil;
    [_interstitialView release];
    [_configuration release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _interstitialView.frame = self.view.bounds;
    _interstitialView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_interstitialView];
}

#pragma mark - Public

- (void)startLoading
{
    [_interstitialView loadCreativeWithHTMLString:[_configuration adResponseHTMLString]
                                          baseURL:nil];
}

- (BOOL)shouldDisplayCloseButton
{
    return !_advertisementHasCustomCloseButton;
}

- (void)willPresentInterstitial
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillAppear:)]) {
        [self.delegate interstitialWillAppear:self];
    }
}

- (void)didPresentInterstitial
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidAppear:)]) {
        [self.delegate interstitialDidAppear:self];
    }
}

- (void)willDismissInterstitial
{
    if ([self.delegate respondsToSelector:@selector(interstitialWillDisappear:)]) {
        [self.delegate interstitialWillDisappear:self];
    }
}

- (void)didDismissInterstitial
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidDisappear:)]) {
        [self.delegate interstitialDidDisappear:self];
    }
}

#pragma mark - MRAdViewDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (MPAdConfigurationSKZ *)adConfiguration
{
    return _configuration;
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adDidLoad:(MRAdViewSKZ *)adView
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
        [self.delegate interstitialDidLoadAd:self];
    }
}

- (void)adDidFailToLoad:(MRAdViewSKZ *)adView
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToLoadAd:)]) {
        [self.delegate interstitialDidFailToLoadAd:self];
    }
}

- (void)adWillClose:(MRAdViewSKZ *)adView
{
    [self dismissInterstitialAnimated:YES];
}

- (void)adDidClose:(MRAdViewSKZ *)adView
{
    // TODO:
}

- (void)ad:(MRAdViewSKZ *)adView didRequestCustomCloseEnabled:(BOOL)enabled
{
    _advertisementHasCustomCloseButton = enabled;
    [self layoutCloseButton];
}

- (void)appShouldSuspendForAd:(MRAdViewSKZ *)adView
{

}

- (void)appShouldResumeFromAd:(MRAdViewSKZ *)adView
{

}

@end
