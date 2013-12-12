//
//  MPInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGlobal.h"


@class MPAdConfigurationSKZ;

// Fetching Ads
@class MPAdServerCommunicatorSKZ;
@protocol MPAdServerCommunicatorDelegateSKZ;

// Banners
@class MPBannerAdManagerSKZ;
@protocol MPBannerAdManagerDelegateSKZ;
@class MPBaseBannerAdapterSKZ;
@protocol MPBannerAdapterDelegateSKZ;
@class MPBannerCustomEventSKZ;
@protocol MPBannerCustomEventDelegateSKZ;

// Interstitials
@class MPInterstitialAdManagerSKZ;
@protocol MPInterstitialAdManagerDelegateSKZ;
@class MPBaseInterstitialAdapterSKZ;
@protocol MPInterstitialAdapterDelegateSKZ;
@class MPInterstitialCustomEventSKZ;
@protocol MPInterstitialCustomEventDelegateSKZ;
@class MPHTMLInterstitialViewControllerSKZ;
@class MPMRAIDInterstitialViewControllerSKZ;
@protocol MPInterstitialViewControllerDelegateSKZ;

// HTML Ads
@class MPAdWebViewSKZ;
@class MPAdWebViewAgentSKZ;
@protocol MPAdWebViewAgentDelegateSKZ;

// URL Handling
@class MPURLResolverSKZ;
@class MPAdDestinationDisplayAgentSKZ;
@protocol MPAdDestinationDisplayAgentDelegateSKZ;

// MRAID
@class MRBundleManagerSKZ;
@class MRJavaScriptEventEmitterSKZ;
@class MRCalendarManagerSKZ;
@protocol MRCalendarManagerDelegateSKZ;
@class EKEventStore;
@class EKEventEditViewController;
@protocol EKEventEditViewDelegate;
@class MRPictureManagerSKZ;
@protocol MRPictureManagerDelegateSKZ;
@class MRImageDownloaderSKZ;
@protocol MRImageDownloaderDelegateSKZ;
@class MRVideoPlayerManagerSKZ;
@protocol MRVideoPlayerManagerDelegateSKZ;

// Utilities
@class MPAdAlertManager, MPAdAlertGestureRecognizer;
@class MPAnalyticsTrackerSKZ;
@class MPReachabilitySKZ;
@class MPTimerSKZ;
@class MPMoviePlayerViewController;

typedef id(^MPSingletonProviderBlock)();

@interface MPInstanceProviderSKZ : NSObject

+ (MPInstanceProviderSKZ *)sharedProvider;
- (id)singletonForClass:(Class)klass provider:(MPSingletonProviderBlock)provider;

#pragma mark - Fetching Ads
- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL;
- (MPAdServerCommunicatorSKZ *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegateSKZ>)delegate;

#pragma mark - Banners
- (MPBannerAdManagerSKZ *)buildMPBannerAdManagerWithDelegate:(id<MPBannerAdManagerDelegateSKZ>)delegate;
- (MPBaseBannerAdapterSKZ *)buildBannerAdapterForConfiguration:(MPAdConfigurationSKZ *)configuration
                                                   delegate:(id<MPBannerAdapterDelegateSKZ>)delegate;
- (MPBannerCustomEventSKZ *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegateSKZ>)delegate;

#pragma mark - Interstitials
- (MPInterstitialAdManagerSKZ *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegateSKZ>)delegate;
- (MPBaseInterstitialAdapterSKZ *)buildInterstitialAdapterForConfiguration:(MPAdConfigurationSKZ *)configuration
                                                               delegate:(id<MPInterstitialAdapterDelegateSKZ>)delegate;
- (MPInterstitialCustomEventSKZ *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegateSKZ>)delegate;
- (MPHTMLInterstitialViewControllerSKZ *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegateSKZ>)delegate
                                                                        orientationType:(MPInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate;
- (MPMRAIDInterstitialViewControllerSKZ *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegateSKZ>)delegate
                                                                            configuration:(MPAdConfigurationSKZ *)configuration;

#pragma mark - HTML Ads
- (MPAdWebViewSKZ *)buildMPAdWebViewWithFrame:(CGRect)frame
                                  delegate:(id<UIWebViewDelegate>)delegate;
- (MPAdWebViewAgentSKZ *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame
                                                     delegate:(id<MPAdWebViewAgentDelegateSKZ>)delegate
                                         customMethodDelegate:(id)customMethodDelegate;

#pragma mark - URL Handling
- (MPURLResolverSKZ *)buildMPURLResolver;
- (MPAdDestinationDisplayAgentSKZ *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegateSKZ>)delegate;

#pragma mark - MRAID
- (MRBundleManagerSKZ *)buildMRBundleManager;
- (UIWebView *)buildUIWebViewWithFrame:(CGRect)frame;
- (MRJavaScriptEventEmitterSKZ *)buildMRJavaScriptEventEmitterWithWebView:(UIWebView *)webView;
- (MRCalendarManagerSKZ *)buildMRCalendarManagerWithDelegate:(id<MRCalendarManagerDelegateSKZ>)delegate;
- (EKEventEditViewController *)buildEKEventEditViewControllerWithEditViewDelegate:(id<EKEventEditViewDelegate>)editViewDelegate;
- (EKEventStore *)buildEKEventStore;
- (MRPictureManagerSKZ *)buildMRPictureManagerWithDelegate:(id<MRPictureManagerDelegateSKZ>)delegate;
- (MRImageDownloaderSKZ *)buildMRImageDownloaderWithDelegate:(id<MRImageDownloaderDelegateSKZ>)delegate;
- (MRVideoPlayerManagerSKZ *)buildMRVideoPlayerManagerWithDelegate:(id<MRVideoPlayerManagerDelegateSKZ>)delegate;
- (MPMoviePlayerViewController *)buildMPMoviePlayerViewControllerWithURL:(NSURL *)URL;

#pragma mark - Utilities
- (id<MPAdAlertManagerProtocolSKZ>)buildMPAdAlertManagerWithDelegate:(id)delegate;
- (MPAdAlertGestureRecognizer *)buildMPAdAlertGestureRecognizerWithTarget:(id)target action:(SEL)action;
- (NSOperationQueue *)sharedOperationQueue;
- (MPAnalyticsTrackerSKZ *)sharedMPAnalyticsTracker;
- (MPReachabilitySKZ *)sharedMPReachability;

// This call may return nil and may not update if the user hot-swaps the device's sim card.
- (NSDictionary *)sharedCarrierInfo;

- (MPTimerSKZ *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats;

@end
