//
//  MRAdView.h
//  MoPub
//
//  Created by Andrew He on 12/20/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPAdDestinationDisplayAgentSKZ.h"
#import "MRCalendarManagerSKZ.h"
#import "MRPictureManagerSKZ.h"
#import "MRVideoPlayerManagerSKZ.h"

@class MRAdViewDisplayControllerSKZ, MRPropertySKZ, MPAdConfigurationSKZ;
@protocol MRAdViewDelegateSKZ;

enum {
    MRAdViewStateHidden = 0,
    MRAdViewStateDefault = 1,
    MRAdViewStateExpanded = 2
};
typedef NSUInteger MRAdViewState;

enum {
    MRAdViewPlacementTypeInline,
    MRAdViewPlacementTypeInterstitial
};
typedef NSUInteger MRAdViewPlacementType;

enum {
    MRAdViewCloseButtonStyleAlwaysHidden,
    MRAdViewCloseButtonStyleAlwaysVisible,
    MRAdViewCloseButtonStyleAdControlled
};
typedef NSUInteger MRAdViewCloseButtonStyle;

enum {
    MRAdViewAdTypeDefault,
    MRAdViewAdTypePreCached
};
typedef NSUInteger MRAdViewAdType;

@interface MRAdViewSKZ : UIView <UIWebViewDelegate, MPAdDestinationDisplayAgentDelegateSKZ, MRCalendarManagerDelegateSKZ, MRPictureManagerDelegateSKZ, MRVideoPlayerManagerDelegateSKZ> {
    // This view's delegate object.
    id<MRAdViewDelegateSKZ> _delegate;

    // The underlying webview.
    UIWebView *_webView;

    // The native close button, shown when this view is used as an interstitial ad, or when the ad
    // is expanded.
    UIButton *_closeButton;

    // Stores the HTML payload of a creative, when loading a creative from an NSURL.
    NSMutableData *_data;

    // Performs display-related actions, such as expanding and closing the ad.
    MRAdViewDisplayControllerSKZ *_displayController;

    // Flag indicating whether this view is currently loading an ad.
    BOOL _isLoading;

    // The number of modal views this ad has presented.
    NSInteger _modalViewCount;

    // Flag indicating whether this view's ad content provides its own custom (non-native) close
    // button.
    BOOL _usesCustomCloseButton;

    MRAdViewCloseButtonStyle _closeButtonStyle;

    // Flag indicating whether ads presented in this view are allowed to use the expand() API.
    BOOL _allowsExpansion;

    BOOL _expanded;

    // Enum indicating whether this view is being used as an inline ad or an interstitial ad.
    MRAdViewPlacementType _placementType;

    // Enum indicating the type of this ad. Default ad or ad that requires pre-caching.
    MRAdViewAdType _adType;
}

@property (nonatomic, assign) id<MRAdViewDelegateSKZ> delegate;
@property (nonatomic, assign) BOOL usesCustomCloseButton;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, retain) MRAdViewDisplayControllerSKZ *displayController;
@property (nonatomic, assign) MRAdViewAdType adType;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame allowsExpansion:(BOOL)expansion
   closeButtonStyle:(MRAdViewCloseButtonStyle)style placementType:(MRAdViewPlacementType)type;
- (void)loadCreativeFromURL:(NSURL *)url;
- (void)loadCreativeWithHTMLString:(NSString *)html baseURL:(NSURL *)url;

- (BOOL)isViewable;
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;
- (void)handleMRAIDOpenCallForURL:(NSURL *)URL;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MRAdViewDelegateSKZ <NSObject>

@required

- (NSString *)adUnitId;

- (MPAdConfigurationSKZ *)adConfiguration;

- (CLLocation *)location;

// Retrieves the view controller from which modal views should be presented.
- (UIViewController *)viewControllerForPresentingModalView;

// Called when the ad is about to display modal content (thus taking over the screen).
- (void)appShouldSuspendForAd:(MRAdViewSKZ *)adView;

// Called when the ad has dismissed any modal content (removing any on-screen takeovers).
- (void)appShouldResumeFromAd:(MRAdViewSKZ *)adView;

@optional

// Called when the ad loads successfully.
- (void)adDidLoad:(MRAdViewSKZ *)adView;

// Called when the ad fails to load.
- (void)adDidFailToLoad:(MRAdViewSKZ *)adView;

// Called just before the ad is displayed on-screen.
- (void)adWillShow:(MRAdViewSKZ *)adView;

// Called just after the ad has been displayed on-screen.
- (void)adDidShow:(MRAdViewSKZ *)adView;

// Called just before the ad is hidden.
- (void)adWillHide:(MRAdViewSKZ *)adView;

// Called just after the ad has been hidden.
- (void)adDidHide:(MRAdViewSKZ *)adView;

// Called just before the ad expands.
- (void)willExpandAd:(MRAdViewSKZ *)adView
             toFrame:(CGRect)frame;

// Called just after the ad has expanded.
- (void)didExpandAd:(MRAdViewSKZ *)adView
            toFrame:(CGRect)frame;

// Called just before the ad closes.
- (void)adWillClose:(MRAdViewSKZ *)adView;

// Called just after the ad has closed.
- (void)adDidClose:(MRAdViewSKZ *)adView;

- (void)ad:(MRAdViewSKZ *)adView didRequestCustomCloseEnabled:(BOOL)enabled;

@end
