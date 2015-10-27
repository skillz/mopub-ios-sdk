//
//  MRAdView.m
//  MoPub
//
//  Created by Andrew He on 12/20/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import "MRAdViewSKZ.h"
#import "UIWebView+MPAdditions.h"
#import "MPGlobal.h"
#import "MPLogging.h"
#import "MRAdViewDisplayControllerSKZ.h"
#import "MRCommandSKZ.h"
#import "MRPropertySKZ.h"
#import "MPInstanceProviderSKZ.h"
#import "MRCalendarManagerSKZ.h"
#import "MRJavaScriptEventEmitterSKZ.h"
#import "UIViewController+MPAdditions.h"
#import "MRBundleManagerSKZ.h"

static NSString *const kExpandableCloseButtonImageName = @"MPCloseButtonX_SKZ";
static NSString *const kMraidURLScheme = @"mraid";
static NSString *const kMoPubURLScheme = @"mopub";
static NSString *const kMoPubPrecacheCompleteHost = @"precacheComplete";

@interface MRAdViewSKZ ()

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) MPAdDestinationDisplayAgentSKZ *destinationDisplayAgent;
@property (nonatomic, strong) MRCalendarManagerSKZ *calendarManager;
@property (nonatomic, strong) MRPictureManagerSKZ *pictureManager;
@property (nonatomic, strong) MRVideoPlayerManagerSKZ *videoPlayerManager;
@property (nonatomic, strong) MRJavaScriptEventEmitterSKZ *jsEventEmitter;
@property (nonatomic, strong) id<MPAdAlertManagerProtocolSKZ> adAlertManager;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

- (NSMutableString *)HTMLWithJavaScriptBridge:(NSString *)HTML;
- (BOOL)HTMLStringIsMRAIDFragment:(NSString *)string;
- (NSMutableString *)fullHTMLFromMRAIDFragment:(NSString *)fragment;
- (NSString *)MRAIDScriptPath;

- (void)layoutCloseButton;
- (void)initializeJavascriptState;

// Delegate callback methods wrapped with -respondsToSelector: checks.
- (void)adDidLoad;
- (void)adDidFailToLoad;
- (void)adWillClose;
- (void)adDidClose;
- (void)adDidRequestCustomCloseEnabled:(BOOL)enabled;
- (void)adWillExpandToFrame:(CGRect)frame;
- (void)adDidExpandToFrame:(CGRect)frame;
- (void)adWillPresentModalView;
- (void)adDidDismissModalView;
- (void)appShouldSuspend;
- (void)appShouldResume;
- (void)adViewableDidChange:(BOOL)viewable;

@end

@implementation MRAdViewSKZ

@synthesize delegate = _delegate;
@synthesize usesCustomCloseButton = _usesCustomCloseButton;
@synthesize expanded = _expanded;
@synthesize data = _data;
@synthesize displayController = _displayController;
@synthesize destinationDisplayAgent = _destinationDisplayAgent;
@synthesize calendarManager = _calendarManager;
@synthesize pictureManager = _pictureManager;
@synthesize videoPlayerManager = _videoPlayerManager;
@synthesize jsEventEmitter = _jsEventEmitter;
@synthesize adAlertManager = _adAlertManager;
@synthesize adType = _adType;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame
               allowsExpansion:YES
              closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                 placementType:MRAdViewPlacementTypeInline];
}

- (id)initWithFrame:(CGRect)frame allowsExpansion:(BOOL)expansion
   closeButtonStyle:(MRAdViewCloseButtonStyle)style placementType:(MRAdViewPlacementType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;

        _webView = [[MPInstanceProviderSKZ sharedProvider] buildUIWebViewWithFrame:frame];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.clipsToBounds = YES;
        _webView.delegate = self;
        _webView.opaque = NO;
        [_webView mp_setScrollableSKZ:NO];

        if ([_webView respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
            [_webView setAllowsInlineMediaPlayback:YES];
        }

        if ([_webView respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
            [_webView setMediaPlaybackRequiresUserAction:NO];
        }

        [self addSubview:_webView];

        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(0, 0, 50, 50);
        UIImage *image = [UIImage imageFromResource:kExpandableCloseButtonImageName];
        [_closeButton setImage:image forState:UIControlStateNormal];

        _allowsExpansion = expansion;
        _closeButtonStyle = style;
        _placementType = type;

        _displayController = [[MRAdViewDisplayControllerSKZ alloc] initWithAdView:self
                                                               allowsExpansion:expansion
                                                              closeButtonStyle:style
                                                               jsEventEmitter:[[MPInstanceProviderSKZ sharedProvider] buildMRJavaScriptEventEmitterWithWebView:_webView]];

        [_closeButton addTarget:_displayController
                         action:@selector(closeButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];

        _destinationDisplayAgent = [[MPInstanceProviderSKZ sharedProvider]
                                    buildMPAdDestinationDisplayAgentWithDelegate:self];
        _calendarManager = [[MPInstanceProviderSKZ sharedProvider]
                             buildMRCalendarManagerWithDelegate:self];
        _pictureManager = [[MPInstanceProviderSKZ sharedProvider]
                             buildMRPictureManagerWithDelegate:self];
        _videoPlayerManager = [[MPInstanceProviderSKZ sharedProvider]
                                buildMRVideoPlayerManagerWithDelegate:self];
        _jsEventEmitter = [[MPInstanceProviderSKZ sharedProvider]
                             buildMRJavaScriptEventEmitterWithWebView:_webView];

        self.adAlertManager = [[MPInstanceProviderSKZ sharedProvider] buildMPAdAlertManagerWithDelegate:self];

        self.adType = MRAdViewAdTypeDefault;
    }
    return self;
}

- (void)dealloc
{
    _webView.delegate = nil;
    [_destinationDisplayAgent setDelegate:nil];
    [_calendarManager setDelegate:nil];
    [_pictureManager setDelegate:nil];
    [_videoPlayerManager setDelegate:nil];
    self.adAlertManager.targetAdView = nil;
    self.adAlertManager.delegate = nil;
}

#pragma mark - <MPAdAlertManagerDelegate>

- (UIViewController *)viewControllerForPresentingMailVC
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adAlertManagerDidTriggerAlert:(MPAdAlertManagerSKZ *)manager
{
    [self.adAlertManager processAdAlertOnce];
}

#pragma mark - Public

- (void)setDelegate:(id<MRAdViewDelegateSKZ>)delegate
{
    [_closeButton removeTarget:delegate
                        action:NULL
              forControlEvents:UIControlEventTouchUpInside];

    _delegate = delegate;

    [_closeButton addTarget:_delegate
                     action:@selector(closeButtonPressed)
           forControlEvents:UIControlEventTouchUpInside];
}

- (void)setExpanded:(BOOL)expanded
{
    _expanded = expanded;
    [self layoutCloseButton];
}

- (void)setUsesCustomCloseButton:(BOOL)shouldUseCustomCloseButton
{
    _usesCustomCloseButton = shouldUseCustomCloseButton;
    [self layoutCloseButton];
}

- (BOOL)isViewable
{
    return MPViewIsVisible(self);
}

- (void)loadCreativeFromURL:(NSURL *)url
{
    [_displayController revertViewToDefaultState];
    _isLoading = YES;
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadCreativeWithHTMLString:(NSString *)html baseURL:(NSURL *)url
{
    [_displayController revertViewToDefaultState];
    _isLoading = YES;
    [self loadHTMLString:html baseURL:url];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [_displayController rotateToOrientation:newOrientation];
}

- (NSString *)placementType
{
    switch (_placementType) {
        case MRAdViewPlacementTypeInline:
            return @"inline";
        case MRAdViewPlacementTypeInterstitial:
            return @"interstitial";
        default:
            return @"unknown";
    }
}

- (void)handleMRAIDOpenCallForURL:(NSURL *)URL
{
    [self.destinationDisplayAgent displayDestinationForURL:URL];
}

#pragma mark - Private

- (void)initAdAlertManager
{
    self.adAlertManager.adConfiguration = [self.delegate adConfiguration];
    self.adAlertManager.adUnitId = [self.delegate adUnitId];
    self.adAlertManager.targetAdView = self;
    self.adAlertManager.location = [self.delegate location];
    [self.adAlertManager beginMonitoringAlerts];
}

- (void)loadRequest:(NSURLRequest *)request
{
    [self initAdAlertManager];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        self.data = [NSMutableData data];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [self initAdAlertManager];

    // Bail out if we can't locate mraid.js.
    if (![self MRAIDScriptPath]) {
        [self adDidFailToLoad];
        return;
    }

    NSString *HTML = [self HTMLWithJavaScriptBridge:string];
    if (HTML) {
        [_webView disableJavaScriptDialogsSKZ];
        [_webView loadHTMLString:HTML baseURL:baseURL];
    }
}

- (NSMutableString *)HTMLWithJavaScriptBridge:(NSString *)HTML
{
    NSMutableString *resultHTML = [HTML mutableCopy];

    if ([self HTMLStringIsMRAIDFragment:HTML]) {
        MPLogDebug(@"Fragment detected: converting to full payload.");
        resultHTML = [self fullHTMLFromMRAIDFragment:resultHTML];
    }

    NSURL *MRAIDScriptURL = [NSURL fileURLWithPath:[self MRAIDScriptPath]];

    NSRange headTagRange = [resultHTML rangeOfString:@"<head>"];
    NSString *MRAIDScriptTag = [NSString stringWithFormat:@"<script src='%@'></script>",
                                [MRAIDScriptURL absoluteString]];
    [resultHTML insertString:MRAIDScriptTag atIndex:headTagRange.location + headTagRange.length];

    return resultHTML;
}

- (BOOL)HTMLStringIsMRAIDFragment:(NSString *)string
{
    return ([string rangeOfString:@"<html>"].location == NSNotFound ||
            [string rangeOfString:@"<head>"].location == NSNotFound);
}

- (NSMutableString *)fullHTMLFromMRAIDFragment:(NSString *)fragment
{
    NSMutableString *result = [fragment mutableCopy];

    NSString *prepend = @"<html><head>"
        @"<meta name='viewport' content='user-scalable=no; initial-scale=1.0'/>"
        @"</head>"
        @"<body style='margin:0;padding:0;overflow:hidden;background:transparent;'>";
    [result insertString:prepend atIndex:0];
    [result appendString:@"</body></html>"];

    return result;
}

- (NSString *)MRAIDScriptPath
{
    MRBundleManagerSKZ *bundleManager = [[MPInstanceProviderSKZ sharedProvider] buildMRBundleManager];
    return [bundleManager mraidPath];
}

- (void)layoutCloseButton
{
    if (!_usesCustomCloseButton) {
        CGRect frame = _closeButton.frame;
        frame.origin.x = CGRectGetWidth(CGRectApplyAffineTransform(self.frame, self.transform)) -
                _closeButton.frame.size.width;
        _closeButton.frame = frame;
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_closeButton];
        [self bringSubviewToFront:_closeButton];
    } else {
        [_closeButton removeFromSuperview];
    }
}

- (void)initializeJavascriptState
{
    MPLogDebug(@"Injecting initial JavaScript state.");
    [_displayController initializeJavascriptStateWithViewProperties:@[
            [MRPlacementTypePropertySKZ propertyWithType:_placementType],
            [MRSupportsPropertySKZ defaultProperty]]];
}

- (void)handleCommandWithURL:(NSURL *)URL
{
    NSString *command = URL.host;
    NSDictionary *parameters = MPDictionaryFromQueryString(URL.query);
    BOOL success = YES;

    if ([command isEqualToString:@"createCalendarEvent"]) {
        [self.calendarManager createCalendarEventWithParameters:parameters];
    } else if ([command isEqualToString:@"playVideo"]) {
        [self.videoPlayerManager playVideo:parameters];
    } else if ([command isEqualToString:@"storePicture"]) {
        [self.pictureManager storePicture:parameters];
    } else {
        // TODO: Refactor legacy MRAID command handling.
        MRCommandSKZ *cmd = [MRCommandSKZ commandForString:command];
        cmd.parameters = parameters;
        cmd.view = self;
        success = [cmd execute];
    }

    [self.jsEventEmitter fireNativeCommandCompleteEvent:command];

    if (!success) {
        MPLogDebug(@"Unknown command: %@", command);
        [self.jsEventEmitter fireErrorEventForAction:command withMessage:@"Specified command is not implemented."];
    }
}

- (void)performActionForMoPubSpecificURL:(NSURL *)url
{
    MPLogDebug(@"MRAdView - loading MoPub URL: %@", url);
    NSString *host = [url host];
    if ([host isEqualToString:kMoPubPrecacheCompleteHost] && self.adType == MRAdViewAdTypePreCached) {
        [self adDidLoad];
    } else {
        MPLogWarn(@"MRAdView - unsupported MoPub URL: %@", [url absoluteString]);
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self adDidFailToLoad];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *str = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    [self loadHTMLString:str baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSMutableString *urlString = [NSMutableString stringWithString:[url absoluteString]];
    NSString *scheme = url.scheme;

    if ([scheme isEqualToString:kMraidURLScheme]) {
        MPLogDebug(@"Trying to process command: %@", urlString);
        [self handleCommandWithURL:url];
        return NO;
    } else if ([scheme isEqualToString:kMoPubURLScheme]) {
        [self performActionForMoPubSpecificURL:url];
        return NO;
    } else if ([scheme isEqualToString:@"ios-log"]) {
        [urlString replaceOccurrencesOfString:@"%20"
                                   withString:@" "
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [urlString length])];
        MPLogDebug(@"Web console: %@", urlString);
        return NO;
    }

    if (!_isLoading && (navigationType == UIWebViewNavigationTypeOther ||
            navigationType == UIWebViewNavigationTypeLinkClicked)) {
        BOOL iframe = ![request.URL isEqual:request.mainDocumentURL];
        if (iframe) return YES;

        [self.destinationDisplayAgent displayDestinationForURL:url];
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_webView disableJavaScriptDialogsSKZ];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_isLoading) {
        _isLoading = NO;
        [self initializeJavascriptState];

        switch (self.adType) {
            case MRAdViewAdTypeDefault:
                [self adDidLoad];
                break;
            case MRAdViewAdTypePreCached:
                // wait for the ad to tell us it's done precaching before we notify the publisher
                break;
            default:
                break;
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code == NSURLErrorCancelled) return;
    _isLoading = NO;
    [self adDidFailToLoad];
}

#pragma mark - <MPAdDestinationDisplayAgentDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)displayAgentWillPresentModal
{
    [self adWillPresentModalView];
}

- (void)displayAgentDidDismissModal
{
    [self adDidDismissModalView];
}

- (void)displayAgentWillLeaveApplication
{
    // Do nothing.
}

#pragma mark - <MRCalendarManagerDelegate>

- (void)calendarManager:(MRCalendarManagerSKZ *)manager
        didFailToCreateCalendarEventWithErrorMessage:(NSString *)message
{
    [self.jsEventEmitter fireErrorEventForAction:@"createCalendarEvent"
                                      withMessage:message];
}

- (void)calendarManagerWillPresentCalendarEditor:(MRCalendarManagerSKZ *)manager
{
    [self adWillPresentModalView];
}

- (void)calendarManagerDidDismissCalendarEditor:(MRCalendarManagerSKZ *)manager
{
    [self adDidDismissModalView];
}

- (UIViewController *)viewControllerForPresentingCalendarEditor
{
    return [self viewControllerForPresentingModalView];
}

#pragma mark - <MRPictureManagerDelegate>

- (void)pictureManager:(MRPictureManagerSKZ *)manager didFailToStorePictureWithErrorMessage:(NSString *)message
{
    [self.jsEventEmitter fireErrorEventForAction:@"storePicture"
                                     withMessage:message];
}

#pragma mark - <MRVideoPlayerManagerDelegate>

- (void)videoPlayerManager:(MRVideoPlayerManagerSKZ *)manager didFailToPlayVideoWithErrorMessage:(NSString *)message
{
    [self.jsEventEmitter fireErrorEventForAction:@"playVideo"
                                     withMessage:message];
}

- (void)videoPlayerManagerWillPresentVideo:(MRVideoPlayerManagerSKZ *)manager
{
    [self adWillPresentModalView];
}

- (void)videoPlayerManagerDidDismissVideo:(MRVideoPlayerManagerSKZ *)manager
{
    [self adDidDismissModalView];
}

- (UIViewController *)viewControllerForPresentingVideoPlayer
{
    return [self viewControllerForPresentingModalView];
}

#pragma mark - Delegation Wrappers

- (void)adDidLoad
{
    if ([self.delegate respondsToSelector:@selector(adDidLoad:)]) {
        [self.delegate adDidLoad:self];
    }
}

- (void)adDidFailToLoad
{
    if ([self.delegate respondsToSelector:@selector(adDidFailToLoad:)]) {
        [self.delegate adDidFailToLoad:self];
    }
}

- (void)adWillClose
{
    if ([self.delegate respondsToSelector:@selector(adWillClose:)]) {
        [self.delegate adWillClose:self];
    }
}

- (void)adDidClose
{
    if ([self.delegate respondsToSelector:@selector(adDidClose:)]) {
        [self.delegate adDidClose:self];
    }
}

- (void)adWillExpandToFrame:(CGRect)frame
{
    if ([self.delegate respondsToSelector:@selector(willExpandAd:toFrame:)]) {
        [self.delegate willExpandAd:self toFrame:frame];
    }
}

- (void)adDidExpandToFrame:(CGRect)frame
{
    if ([self.delegate respondsToSelector:@selector(didExpandAd:toFrame:)]) {
        [self.delegate didExpandAd:self toFrame:frame];
    }
}

- (void)adDidRequestCustomCloseEnabled:(BOOL)enabled
{
    if ([self.delegate respondsToSelector:@selector(ad:didRequestCustomCloseEnabled:)]) {
        [self.delegate ad:self didRequestCustomCloseEnabled:enabled];
    }
}

- (void)adWillPresentModalView
{
    [_displayController additionalModalViewWillPresent];

    _modalViewCount++;
    if (_modalViewCount == 1) [self appShouldSuspend];
}

- (void)adDidDismissModalView
{
    [_displayController additionalModalViewDidDismiss];

    _modalViewCount--;
    if (_modalViewCount == 0) [self appShouldResume];
}

- (void)appShouldSuspend
{
    if ([self.delegate respondsToSelector:@selector(appShouldSuspendForAd:)]) {
        [self.delegate appShouldSuspendForAd:self];
    }
}

- (void)appShouldResume
{
    if ([self.delegate respondsToSelector:@selector(appShouldResumeFromAd:)]) {
        [self.delegate appShouldResumeFromAd:self];
    }
}

- (void)adViewableDidChange:(BOOL)viewable
{
    [self.jsEventEmitter fireChangeEventForProperty:[MRViewablePropertySKZ propertyWithViewable:viewable]];
}

@end
