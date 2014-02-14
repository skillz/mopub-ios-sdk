//
//  MPAdDestinationDisplayAgent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdDestinationDisplayAgentSKZ.h"
#import "UIViewController+MPAdditions.h"
#import "MPInstanceProviderSKZ.h"
#import "MPLastResortDelegateSKZ.h"

@interface MPAdDestinationDisplayAgentSKZ ()

@property (nonatomic, strong) MPURLResolverSKZ *resolver;
@property (nonatomic, strong) MPProgressOverlayViewSKZ *overlayView;
@property (nonatomic, assign) BOOL isLoadingDestination;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
@property (nonatomic, strong) SKStoreProductViewController *storeKitController;
#endif

@property (nonatomic, strong) MPAdBrowserControllerSKZ *browserController;

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL;
- (void)hideOverlay;
- (void)hideModalAndNotifyDelegate;
- (void)dismissAllModalContent;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdDestinationDisplayAgentSKZ

@synthesize delegate = _delegate;
@synthesize resolver = _resolver;
@synthesize isLoadingDestination = _isLoadingDestination;

+ (MPAdDestinationDisplayAgentSKZ *)agentWithDelegate:(id<MPAdDestinationDisplayAgentDelegateSKZ>)delegate
{
    MPAdDestinationDisplayAgentSKZ *agent = [[MPAdDestinationDisplayAgentSKZ alloc] init];
    agent.delegate = delegate;
    agent.resolver = [[MPInstanceProviderSKZ sharedProvider] buildMPURLResolver];
    agent.overlayView = [[MPProgressOverlayViewSKZ alloc] initWithDelegate:agent];
    return agent;
}

- (void)dealloc
{
    [self dismissAllModalContent];

    self.overlayView.delegate = nil;
    self.resolver.delegate = nil;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
    // XXX: If this display agent is deallocated while a StoreKit controller is still on-screen,
    // nil-ing out the controller's delegate would leave us with no way to dismiss the controller
    // in the future. Therefore, we change the controller's delegate to a singleton object which
    // implements SKStoreProductViewControllerDelegate and is always around.
    self.storeKitController.delegate = [MPLastResortDelegateSKZ sharedDelegate];
#endif
    self.browserController.delegate = nil;

}

- (void)dismissAllModalContent
{
    [self.overlayView hide];
}

- (void)displayDestinationForURL:(NSURL *)URL
{
    if (self.isLoadingDestination) return;
    self.isLoadingDestination = YES;

    [self.delegate displayAgentWillPresentModal];
    [self.overlayView show];

    [self.resolver startResolvingWithURL:URL delegate:self];
}

- (void)cancel
{
    if (self.isLoadingDestination) {
        self.isLoadingDestination = NO;
        [self.resolver cancel];
        [self hideOverlay];
        [self.delegate displayAgentDidDismissModal];
    }
}

#pragma mark - <MPURLResolverDelegate>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL
{
    [self hideOverlay];

    self.browserController = [[MPAdBrowserControllerSKZ alloc] initWithURL:URL
                                                              HTMLString:HTMLString
                                                                delegate:self];
    self.browserController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewControllerSKZ:self.browserController
                                                                               animated:MP_ANIMATED];
}

- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL
{
    if ([MPStoreKitProviderSKZ deviceHasStoreKit]) {
        [self presentStoreKitControllerWithItemIdentifier:parameter fallbackURL:URL];
    } else {
        [self openURLInApplication:URL];
    }
}

- (void)openURLInApplication:(NSURL *)URL
{
    [self hideOverlay];
    [self.delegate displayAgentWillLeaveApplication];

    [[UIApplication sharedApplication] openURL:URL];
    self.isLoadingDestination = NO;
}

- (void)failedToResolveURLWithError:(NSError *)error
{
    self.isLoadingDestination = NO;
    [self hideOverlay];
    [self.delegate displayAgentDidDismissModal];
}

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
    self.storeKitController = [MPStoreKitProviderSKZ buildController];
    self.storeKitController.delegate = self;

    NSDictionary *parameters = [NSDictionary dictionaryWithObject:identifier
                                                           forKey:SKStoreProductParameterITunesItemIdentifier];
    [self.storeKitController loadProductWithParameters:parameters completionBlock:nil];

    [self hideOverlay];
    [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewControllerSKZ:self.storeKitController
                                                                               animated:MP_ANIMATED];
#endif
}

#pragma mark - <MPSKStoreProductViewControllerDelegate>
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    self.isLoadingDestination = NO;
    [self hideModalAndNotifyDelegate];
}

#pragma mark - <MPAdBrowserControllerDelegate>
- (void)dismissBrowserController:(MPAdBrowserControllerSKZ *)browserController animated:(BOOL)animated
{
    self.isLoadingDestination = NO;
    [self hideModalAndNotifyDelegate];
}

#pragma mark - <MPProgressOverlayViewDelegate>
- (void)overlayCancelButtonPressed
{
    [self cancel];
}

#pragma mark - Convenience Methods
- (void)hideModalAndNotifyDelegate
{
    [[self.delegate viewControllerForPresentingModalView] mp_dismissModalViewControllerAnimatedSKZ:MP_ANIMATED];
    [self.delegate displayAgentDidDismissModal];
}

- (void)hideOverlay
{
    [self.overlayView hide];
}

@end
