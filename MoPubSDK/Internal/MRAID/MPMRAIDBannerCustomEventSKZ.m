//
//  MPMRAIDBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPMRAIDBannerCustomEventSKZ.h"
#import "MPLogging.h"
#import "MPAdConfigurationSKZ.h"
#import "MPInstanceProviderSKZ.h"

@interface MPMRAIDBannerCustomEventSKZ ()

@property (nonatomic, strong) MRAdViewSKZ *banner;

@end

@implementation MPMRAIDBannerCustomEventSKZ

@synthesize banner = _banner;

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Loading MoPub MRAID banner");
    MPAdConfigurationSKZ *configuration = [self.delegate configuration];

    CGRect adViewFrame = CGRectZero;
    if ([configuration hasPreferredSize]) {
        adViewFrame = CGRectMake(0, 0, configuration.preferredSize.width,
                                 configuration.preferredSize.height);
    }

    self.banner = [[MRAdViewSKZ alloc] initWithFrame:adViewFrame
                                   allowsExpansion:YES
                                  closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                     placementType:MRAdViewPlacementTypeInline];
    self.banner.delegate = self;
    [self.banner loadCreativeWithHTMLString:[configuration adResponseHTMLString]
                                    baseURL:nil];
}

- (void)dealloc
{
    self.banner.delegate = nil;

}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.banner rotateToOrientation:newOrientation];
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
    return [self.delegate configuration];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidLoad:(MRAdViewSKZ *)adView
{
    MPLogInfo(@"MoPub MRAID banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adDidFailToLoad:(MRAdViewSKZ *)adView
{
    MPLogInfo(@"MoPub MRAID banner did fail");
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)closeButtonPressed
{
    //don't care
}

- (void)appShouldSuspendForAd:(MRAdViewSKZ *)adView
{
    MPLogInfo(@"MoPub MRAID banner will begin action");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)appShouldResumeFromAd:(MRAdViewSKZ *)adView
{
    MPLogInfo(@"MoPub MRAID banner did end action");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

@end
