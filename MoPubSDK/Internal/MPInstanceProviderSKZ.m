//
//  MPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInstanceProviderSKZ.h"
#import "MPAdWebViewSKZ.h"
#import "MPAdDestinationDisplayAgentSKZ.h"
#import "MPURLResolverSKZ.h"
#import "MPAdWebViewAgentSKZ.h"
#import "MPInterstitialAdManagerSKZ.h"
#import "MPAdServerCommunicatorSKZ.h"
#import "MPInterstitialCustomEventAdapterSKZ.h"
#import "MPLegacyInterstitialCustomEventAdapterSKZ.h"
#import "MPHTMLInterstitialViewControllerSKZ.h"
#import "MPAnalyticsTrackerSKZ.h"
#import "MPGlobal.h"
#import "MPMRAIDInterstitialViewControllerSKZ.h"
#import "MPReachabilitySKZ.h"
#import "MPTimerSKZ.h"
#import "MPInterstitialCustomEventSKZ.h"
#import "MPBaseBannerAdapterSKZ.h"
#import "MPBannerCustomEventAdapterSKZ.h"
#import "MPLegacyBannerCustomEventAdapterSKZ.h"
#import "MPBannerCustomEventSKZ.h"
#import "MPBannerAdManagerSKZ.h"
#import "MPLogging.h"
#import "MRJavaScriptEventEmitterSKZ.h"
#import "MRImageDownloaderSKZ.h"
#import "MRBundleManagerSKZ.h"
#import "MRCalendarManagerSKZ.h"
#import "MRPictureManagerSKZ.h"
#import "MRVideoPlayerManagerSKZ.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MediaPlayer/MediaPlayer.h>

#define MOPUB_CARRIER_INFO_DEFAULTS_KEY @"com.mopub.carrierinfo"

@interface MPInstanceProviderSKZ ()

@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, retain) NSMutableDictionary *singletons;
@property (nonatomic, retain) NSMutableDictionary *carrierInfo;

@end

@implementation MPInstanceProviderSKZ

@synthesize userAgent = _userAgent;
@synthesize singletons = _singletons;
@synthesize carrierInfo = _carrierInfo;

static MPInstanceProviderSKZ *sharedProvider = nil;

+ (MPInstanceProviderSKZ *)sharedProvider
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedProvider = [[self alloc] init];
    });

    return sharedProvider;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.singletons = [NSMutableDictionary dictionary];

        [self initializeCarrierInfo];
    }
    return self;
}

- (void)dealloc
{
    self.singletons = nil;
    self.carrierInfo = nil;
    [super dealloc];
}

- (id)singletonForClass:(Class)klass provider:(MPSingletonProviderBlock)provider
{
    id singleton = [self.singletons objectForKey:klass];
    if (!singleton) {
        singleton = provider();
        [self.singletons setObject:singleton forKey:(id<NSCopying>)klass];
    }
    return singleton;
}

#pragma mark - Initializing Carrier Info

- (void)initializeCarrierInfo
{
    self.carrierInfo = [NSMutableDictionary dictionary];

    // check if we have a saved copy
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:MOPUB_CARRIER_INFO_DEFAULTS_KEY];
    if(saved != nil) {
        [self.carrierInfo addEntriesFromDictionary:saved];
    }

    // now asynchronously load a fresh copy
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CTTelephonyNetworkInfo *networkInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
        [self performSelectorOnMainThread:@selector(updateCarrierInfoForCTCarrier:) withObject:networkInfo.subscriberCellularProvider waitUntilDone:NO];
    });
}

- (void)updateCarrierInfoForCTCarrier:(CTCarrier *)ctCarrier
{
    // use setValue instead of setObject here because ctCarrier could be nil, and any of its properties could be nil
    [self.carrierInfo setValue:ctCarrier.carrierName forKey:@"carrierName"];
    [self.carrierInfo setValue:ctCarrier.isoCountryCode forKey:@"isoCountryCode"];
    [self.carrierInfo setValue:ctCarrier.mobileCountryCode forKey:@"mobileCountryCode"];
    [self.carrierInfo setValue:ctCarrier.mobileNetworkCode forKey:@"mobileNetworkCode"];

    [[NSUserDefaults standardUserDefaults] setObject:self.carrierInfo forKey:MOPUB_CARRIER_INFO_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Fetching Ads
- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPShouldHandleCookies:YES];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    return request;
}

- (NSString *)userAgent
{
    if (!_userAgent) {
        self.userAgent = [[[[UIWebView alloc] init] autorelease] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }

    return _userAgent;
}

- (MPAdServerCommunicatorSKZ *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegateSKZ>)delegate
{
    return [[(MPAdServerCommunicatorSKZ *)[MPAdServerCommunicatorSKZ alloc] initWithDelegate:delegate] autorelease];
}

#pragma mark - Banners

- (MPBannerAdManagerSKZ *)buildMPBannerAdManagerWithDelegate:(id<MPBannerAdManagerDelegateSKZ>)delegate
{
    return [[(MPBannerAdManagerSKZ *)[MPBannerAdManagerSKZ alloc] initWithDelegate:delegate] autorelease];
}

- (MPBaseBannerAdapterSKZ *)buildBannerAdapterForConfiguration:(MPAdConfigurationSKZ *)configuration
                                                   delegate:(id<MPBannerAdapterDelegateSKZ>)delegate
{
    if (configuration.customEventClass) {
        return [[(MPBannerCustomEventAdapterSKZ *)[MPBannerCustomEventAdapterSKZ alloc] initWithDelegate:delegate] autorelease];
    } else if (configuration.customSelectorName) {
        return [[(MPLegacyBannerCustomEventAdapterSKZ *)[MPLegacyBannerCustomEventAdapterSKZ alloc] initWithDelegate:delegate] autorelease];
    }

    return nil;
}

- (MPBannerCustomEventSKZ *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegateSKZ>)delegate
{
    MPBannerCustomEventSKZ *customEvent = [[[customClass alloc] init] autorelease];
    if (![customEvent isKindOfClass:[MPBannerCustomEventSKZ class]]) {
        MPLogError(@"**** Custom Event Class: %@ does not extend MPBannerCustomEvent ****", NSStringFromClass(customClass));
        return nil;
    }
    customEvent.delegate = delegate;
    return customEvent;
}

#pragma mark - Interstitials

- (MPInterstitialAdManagerSKZ *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegateSKZ>)delegate
{
    return [[(MPInterstitialAdManagerSKZ *)[MPInterstitialAdManagerSKZ alloc] initWithDelegate:delegate] autorelease];
}


- (MPBaseInterstitialAdapterSKZ *)buildInterstitialAdapterForConfiguration:(MPAdConfigurationSKZ *)configuration
                                                               delegate:(id<MPInterstitialAdapterDelegateSKZ>)delegate
{
    if (configuration.customEventClass) {
        return [[(MPInterstitialCustomEventAdapterSKZ *)[MPInterstitialCustomEventAdapterSKZ alloc] initWithDelegate:delegate] autorelease];
    } else if (configuration.customSelectorName) {
        return [[(MPLegacyInterstitialCustomEventAdapterSKZ *)[MPLegacyInterstitialCustomEventAdapterSKZ alloc] initWithDelegate:delegate] autorelease];
    }

    return nil;
}

- (MPInterstitialCustomEventSKZ *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegateSKZ>)delegate
{
    MPInterstitialCustomEventSKZ *customEvent = [[[customClass alloc] init] autorelease];
    if (![customEvent isKindOfClass:[MPInterstitialCustomEventSKZ class]]) {
        MPLogError(@"**** Custom Event Class: %@ does not extend MPInterstitialCustomEvent ****", NSStringFromClass(customClass));
        return nil;
    }
    customEvent.delegate = delegate;
    return customEvent;
}

- (MPHTMLInterstitialViewControllerSKZ *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegateSKZ>)delegate
                                                                        orientationType:(MPInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate
{
    MPHTMLInterstitialViewControllerSKZ *controller = [[[MPHTMLInterstitialViewControllerSKZ alloc] init] autorelease];
    controller.delegate = delegate;
    controller.orientationType = type;
    controller.customMethodDelegate = customMethodDelegate;
    return controller;
}

- (MPMRAIDInterstitialViewControllerSKZ *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegateSKZ>)delegate
                                                                            configuration:(MPAdConfigurationSKZ *)configuration
{
    MPMRAIDInterstitialViewControllerSKZ *controller = [[[MPMRAIDInterstitialViewControllerSKZ alloc] initWithAdConfiguration:configuration] autorelease];
    controller.delegate = delegate;
    return controller;
}

#pragma mark - HTML Ads

- (MPAdWebViewSKZ *)buildMPAdWebViewWithFrame:(CGRect)frame delegate:(id<UIWebViewDelegate>)delegate
{
    MPAdWebViewSKZ *webView = [[[MPAdWebViewSKZ alloc] initWithFrame:frame] autorelease];
    webView.delegate = delegate;
    return webView;
}

- (MPAdWebViewAgentSKZ *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegateSKZ>)delegate customMethodDelegate:(id)customMethodDelegate
{
    return [[[MPAdWebViewAgentSKZ alloc] initWithAdWebViewFrame:frame delegate:delegate customMethodDelegate:customMethodDelegate] autorelease];
}

#pragma mark - URL Handling

- (MPURLResolverSKZ *)buildMPURLResolver
{
    return [MPURLResolverSKZ resolver];
}

- (MPAdDestinationDisplayAgentSKZ *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegateSKZ>)delegate
{
    return [MPAdDestinationDisplayAgentSKZ agentWithDelegate:delegate];
}

#pragma mark - MRAID

- (MRBundleManagerSKZ *)buildMRBundleManager
{
    return [MRBundleManagerSKZ sharedManager];
}

- (UIWebView *)buildUIWebViewWithFrame:(CGRect)frame
{
    return [[[UIWebView alloc] initWithFrame:frame] autorelease];
}

- (MRJavaScriptEventEmitterSKZ *)buildMRJavaScriptEventEmitterWithWebView:(UIWebView *)webView
{
    return [[[MRJavaScriptEventEmitterSKZ alloc] initWithWebView:webView] autorelease];
}

- (MRCalendarManagerSKZ *)buildMRCalendarManagerWithDelegate:(id<MRCalendarManagerDelegateSKZ>)delegate
{
    return [[[MRCalendarManagerSKZ alloc] initWithDelegate:delegate] autorelease];
}

- (EKEventEditViewController *)buildEKEventEditViewControllerWithEditViewDelegate:(id<EKEventEditViewDelegate>)editViewDelegate
{
    EKEventEditViewController *controller = [[[EKEventEditViewController alloc] init] autorelease];
    controller.editViewDelegate = editViewDelegate;
    controller.eventStore = [self buildEKEventStore];
    return controller;
}

- (EKEventStore *)buildEKEventStore
{
    return [[[EKEventStore alloc] init] autorelease];
}

- (MRPictureManagerSKZ *)buildMRPictureManagerWithDelegate:(id<MRPictureManagerDelegateSKZ>)delegate
{
    return [[[MRPictureManagerSKZ alloc] initWithDelegate:delegate] autorelease];
}

- (MRImageDownloaderSKZ *)buildMRImageDownloaderWithDelegate:(id<MRImageDownloaderDelegateSKZ>)delegate
{
    return [[[MRImageDownloaderSKZ alloc] initWithDelegate:delegate] autorelease];
}

- (MRVideoPlayerManagerSKZ *)buildMRVideoPlayerManagerWithDelegate:(id<MRVideoPlayerManagerDelegateSKZ>)delegate
{
    return [[[MRVideoPlayerManagerSKZ alloc] initWithDelegate:delegate] autorelease];
}

- (MPMoviePlayerViewController *)buildMPMoviePlayerViewControllerWithURL:(NSURL *)URL
{
    // ImageContext used to avoid CGErrors
    // http://stackoverflow.com/questions/13203336/iphone-mpmovieplayerviewcontroller-cgcontext-errors/14669166#14669166
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    MPMoviePlayerViewController *playerViewController = [[[MPMoviePlayerViewController alloc] initWithContentURL:URL] autorelease];
    UIGraphicsEndImageContext();

    return playerViewController;
}

#pragma mark - Utilities

- (id<MPAdAlertManagerProtocolSKZ>)buildMPAdAlertManagerWithDelegate:(id)delegate
{
    id<MPAdAlertManagerProtocolSKZ> adAlertManager = nil;

    Class adAlertManagerClass = NSClassFromString(@"MPAdAlertManagerSKZ");
    if(adAlertManagerClass != nil)
    {
        adAlertManager = [[[adAlertManagerClass alloc] init] autorelease];
        [adAlertManager performSelector:@selector(setDelegate:) withObject:delegate];
    }

    return adAlertManager;
}

- (MPAdAlertGestureRecognizer *)buildMPAdAlertGestureRecognizerWithTarget:(id)target action:(SEL)action
{
    MPAdAlertGestureRecognizer *gestureRecognizer = nil;

    Class gestureRecognizerClass = NSClassFromString(@"MPAdAlertGestureRecognizerSKZ");
    if(gestureRecognizerClass != nil)
    {
        gestureRecognizer = [[[gestureRecognizerClass alloc] initWithTarget:target action:action] autorelease];
    }

    return gestureRecognizer;
}

- (NSOperationQueue *)sharedOperationQueue
{
    static NSOperationQueue *sharedOperationQueue = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        sharedOperationQueue = [[NSOperationQueue alloc] init];
    });

    return sharedOperationQueue;
}

- (MPAnalyticsTrackerSKZ *)sharedMPAnalyticsTracker
{
    return [self singletonForClass:[MPAnalyticsTrackerSKZ class] provider:^id{
        return [MPAnalyticsTrackerSKZ tracker];
    }];
}

- (MPReachabilitySKZ *)sharedMPReachability
{
    return [self singletonForClass:[MPReachabilitySKZ class] provider:^id{
        return [MPReachabilitySKZ reachabilityForLocalWiFi];
    }];
}

- (NSDictionary *)sharedCarrierInfo
{
    return self.carrierInfo;
}

- (MPTimerSKZ *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats
{
    return [MPTimerSKZ timerWithTimeInterval:seconds target:target selector:selector repeats:repeats];
}

@end

