//
//  MPAdWebViewAgent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdWebViewAgentSKZ.h"
#import "MPAdConfigurationSKZ.h"
#import "MPGlobal.h"
#import "MPLogging.h"
#import "CJSONDeserializerSKZ.h"
#import "MPAdDestinationDisplayAgentSKZ.h"
#import "NSURL+MPAdditions.h"
#import "UIWebView+MPAdditions.h"
#import "MPAdWebViewSKZ.h"
#import "MPInstanceProviderSKZ.h"

#import "Skillz_private.h"

NSString * const kMoPubURLScheme = @"mopub";
NSString * const kMoPubCloseHost = @"close";
NSString * const kMoPubFinishLoadHost = @"finishLoad";
NSString * const kMoPubFailLoadHost = @"failLoad";
NSString * const kMoPubCustomHost = @"custom";

@interface MPAdWebViewAgentSKZ ()

@property (nonatomic, strong) MPAdConfigurationSKZ *configuration;
@property (nonatomic, strong) MPAdDestinationDisplayAgentSKZ *destinationDisplayAgent;
@property (nonatomic, assign) BOOL shouldHandleRequests;
@property (nonatomic, strong) id<MPAdAlertManagerProtocolSKZ> adAlertManager;

- (void)performActionForMoPubSpecificURL:(NSURL *)URL;
- (BOOL)shouldIntercept:(NSURL *)URL navigationType:(UIWebViewNavigationType)navigationType;
- (void)interceptURL:(NSURL *)URL;
- (void)handleMoPubCustomURL:(NSURL *)URL;

@end

@implementation MPAdWebViewAgentSKZ

@synthesize configuration = _configuration;
@synthesize delegate = _delegate;
@synthesize destinationDisplayAgent = _destinationDisplayAgent;
@synthesize customMethodDelegate = _customMethodDelegate;
@synthesize shouldHandleRequests = _shouldHandleRequests;
@synthesize view = _view;
@synthesize adAlertManager = _adAlertManager;

- (id)initWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegateSKZ>)delegate customMethodDelegate:(id)customMethodDelegate;
{
    self = [super init];
    if (self) {
        self.view = [[MPInstanceProviderSKZ sharedProvider] buildMPAdWebViewWithFrame:frame delegate:self];
        self.destinationDisplayAgent = [[MPInstanceProviderSKZ sharedProvider] buildMPAdDestinationDisplayAgentWithDelegate:self];
        self.delegate = delegate;
        self.customMethodDelegate = customMethodDelegate;
        self.shouldHandleRequests = YES;
        self.adAlertManager = [[MPInstanceProviderSKZ sharedProvider] buildMPAdAlertManagerWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    self.adAlertManager.targetAdView = nil;
    self.adAlertManager.delegate = nil;
    [self.destinationDisplayAgent cancel];
    [self.destinationDisplayAgent setDelegate:nil];
    self.view.delegate = nil;
}

#pragma mark - <MPAdAlertManagerDelegate>

- (UIViewController *)viewControllerForPresentingMailVC
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adAlertManagerDidTriggerAlert:(MPAdAlertManager *)manager
{
    [self.adAlertManager processAdAlertOnce];
}

#pragma mark - Public

- (void)loadConfiguration:(MPAdConfigurationSKZ *)configuration
{
    self.configuration = configuration;

    // Ignore server configuration size for interstitials. At this point our web view
    // is sized correctly for the device's screen. Currently the server sends down values for a 3.5in
    // screen, and they do not size correctly on a 4in screen.
    if (configuration.adType != MPAdTypeInterstitial) {
        if ([configuration hasPreferredSize]) {
            CGRect frame = self.view.frame;
            frame.size.width = configuration.preferredSize.width;
            frame.size.height = configuration.preferredSize.height;
            self.view.frame = frame;
        }
    }

    [self.view mp_setScrollableSKZ:configuration.scrollable];
    [self.view disableJavaScriptDialogsSKZ];
    [self.view loadHTMLString:[configuration adResponseHTMLString]
                         baseURL:nil];

    [self initAdAlertManager];
}

- (void)invokeJavaScriptForEvent:(MPAdWebViewEvent)event
{
    switch (event) {
        case MPAdWebViewEventAdDidAppear:
            [self.view stringByEvaluatingJavaScriptFromString:@"webviewDidAppear();"];
            break;
        case MPAdWebViewEventAdDidDisappear:
            [self.view stringByEvaluatingJavaScriptFromString:@"webviewDidClose();"];
            break;
        default:
            break;
    }
}

- (void)stopHandlingRequests
{
    self.shouldHandleRequests = NO;
    [self.destinationDisplayAgent cancel];
}

- (void)continueHandlingRequests
{
    self.shouldHandleRequests = YES;
}

#pragma mark - <MPAdDestinationDisplayAgentDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)displayAgentWillPresentModal
{
    [self.delegate adActionWillBegin:self.view];
}

- (void)displayAgentWillLeaveApplication
{
    [self.delegate adActionWillLeaveApplication:self.view];
}

- (void)displayAgentDidDismissModal
{
    [self.delegate adActionDidFinish:self.view];
}

#pragma mark - <UIWebViewDelegate>

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{

    //Inteject Skillz Check immediately, then carry on for tracking data, etc.
    NSURL *URL = [request URL];

    if ([URL.scheme isEqualToString:SKZ_DEEP_LINK_SCHEME]) {
        [[Skillz skillzInstance] openDeepLinkingAction:URL.host];
    }
    
    if (!self.shouldHandleRequests) {
        return NO;
    }
    
    if ([[URL scheme] isEqualToString:kMoPubURLScheme]) {
        [self performActionForMoPubSpecificURL:URL];
        return NO;
    } else if ([self shouldIntercept:URL navigationType:navigationType]) {
        [self interceptURL:URL];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.view disableJavaScriptDialogsSKZ];
}

#pragma mark - MoPub-specific URL handlers
- (void)performActionForMoPubSpecificURL:(NSURL *)URL
{
    MPLogDebug(@"MPAdWebView - loading MoPub URL: %@", URL);
    NSString *host = [URL host];
    if ([host isEqualToString:kMoPubCloseHost]) {
        [self.delegate adDidClose:self.view];
    } else if ([host isEqualToString:kMoPubFinishLoadHost]) {
        [self.delegate adDidFinishLoadingAd:self.view];
    } else if ([host isEqualToString:kMoPubFailLoadHost]) {
        [self.delegate adDidFailToLoadAd:self.view];
    } else if ([host isEqualToString:kMoPubCustomHost]) {
        [self handleMoPubCustomURL:URL];
    } else {
        MPLogWarn(@"MPAdWebView - unsupported MoPub URL: %@", [URL absoluteString]);
    }
}

- (void)handleMoPubCustomURL:(NSURL *)URL
{
    NSDictionary *queryParameters = [URL mp_queryAsDictionarySKZ];
    NSString *selectorName = [queryParameters objectForKey:@"fnc"];
    NSString *oneArgumentSelectorName = [selectorName stringByAppendingString:@":"];
    SEL zeroArgumentSelector = NSSelectorFromString(selectorName);
    SEL oneArgumentSelector = NSSelectorFromString(oneArgumentSelectorName);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.customMethodDelegate respondsToSelector:zeroArgumentSelector]) {
        [self.customMethodDelegate performSelector:zeroArgumentSelector];
    } else if ([self.customMethodDelegate respondsToSelector:oneArgumentSelector]) {
        CJSONDeserializerSKZ *deserializer = [CJSONDeserializerSKZ deserializerWithNullObject:NULL];
        NSData *data = [[queryParameters objectForKey:@"data"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDictionary = [deserializer deserializeAsDictionary:data error:NULL];

        [self.customMethodDelegate performSelector:oneArgumentSelector
                                        withObject:dataDictionary];
    } else {
        MPLogError(@"Custom method delegate does not implement custom selectors %@ or %@.",
                   selectorName, oneArgumentSelectorName);
    }
#pragma clang diagnostic pop
}

#pragma mark - URL Interception
- (BOOL)shouldIntercept:(NSURL *)URL navigationType:(UIWebViewNavigationType)navigationType
{
    if (!(self.configuration.shouldInterceptLinks)) {
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return YES;
    } else if (navigationType == UIWebViewNavigationTypeOther) {
        return [[URL absoluteString] hasPrefix:[self.configuration clickDetectionURLPrefix]];
    } else {
        return NO;
    }
}

- (void)interceptURL:(NSURL *)URL
{
    NSURL *redirectedURL = URL;
    if (self.configuration.clickTrackingURL) {
        NSString *path = [NSString stringWithFormat:@"%@&r=%@",
                          self.configuration.clickTrackingURL.absoluteString,
                          [[URL absoluteString] URLEncodedStringSKZ]];
        redirectedURL = [NSURL URLWithString:path];
    }

    [self.destinationDisplayAgent displayDestinationForURL:redirectedURL];
}

#pragma mark - Utility

- (void)initAdAlertManager
{
    self.adAlertManager.adConfiguration = self.configuration;
    self.adAlertManager.adUnitId = [self.delegate adUnitId];
    self.adAlertManager.targetAdView = self.view;
    self.adAlertManager.location = [self.delegate location];
    [self.adAlertManager beginMonitoringAlerts];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    [self forceRedraw];
}

- (void)forceRedraw
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    int angle = -1;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait: angle = 0; break;
        case UIInterfaceOrientationLandscapeLeft: angle = 90; break;
        case UIInterfaceOrientationLandscapeRight: angle = -90; break;
        case UIInterfaceOrientationPortraitUpsideDown: angle = 180; break;
        default: break;
    }

    if (angle == -1) return;

    // UIWebView doesn't seem to fire the 'orientationchange' event upon rotation, so we do it here.
    NSString *orientationEventScript = [NSString stringWithFormat:
                                        @"window.__defineGetter__('orientation',function(){return %d;});"
                                        @"(function(){ var evt = document.createEvent('Events');"
                                        @"evt.initEvent('orientationchange',true,true);window.dispatchEvent(evt);})();",
                                        angle];
    [self.view stringByEvaluatingJavaScriptFromString:orientationEventScript];

    // XXX: If the UIWebView is rotated off-screen (which may happen with interstitials), its
    // content may render off-center upon display. We compensate by setting the viewport meta tag's
    // 'width' attribute to be the size of the webview.
    NSString *viewportUpdateScript = [NSString stringWithFormat:
                                      @"document.querySelector('meta[name=viewport]')"
                                      @".setAttribute('content', 'width=%f;', false);",
                                      self.view.frame.size.width];
    [self.view stringByEvaluatingJavaScriptFromString:viewportUpdateScript];
}

@end