//
//  MPInterstitialViewController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialViewControllerSKZ.h"

#import "MPGlobal.h"
#import "MPLogging.h"
#import "UIViewController+MPAdditions.h"

#import "Skillz_private.h"
#import "UIView+Skillz.h"

static const CGFloat kCloseButtonPadding = 6.0;
static const CGFloat kCloseButtonPaddingForPad = 12.0;
static NSString * const kCloseButtonXImageName = @"MPCloseButtonX_SKZ";

@interface MPInterstitialViewControllerSKZ ()

@property (nonatomic, assign) BOOL applicationHasStatusBar;
@property (nonatomic, assign) BOOL isOnViewControllerStack;

- (void)setCloseButtonImageWithImageNamed:(NSString *)imageName;
- (void)setCloseButtonStyle:(MPInterstitialCloseButtonStyle)style;
- (void)closeButtonPressed;
- (void)dismissInterstitialAnimated:(BOOL)animated;
- (void)setApplicationStatusBarHidden:(BOOL)hidden;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPInterstitialViewControllerSKZ


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.isOnViewControllerStack) {
        self.isOnViewControllerStack = YES;
        [self didPresentInterstitial];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // When the interstitial is dismissed, we want to
    // -viewDidDisappear: is called 1) when the interstitial is dismissed and 2) when a modal view
    // controller is presented atop the interstitial (e.g. the ad browser).

    if (![self mp_presentedViewControllerSKZ]) {
        self.isOnViewControllerStack = NO;
        //self.view.alpha = 0.0;
    }
}

#pragma mark - Public

- (void)presentInterstitialFromViewController:(UIViewController *)controller
{
    if (_isOnViewControllerStack) {
        MPLogWarn(@"Cannot present an interstitial that is already on-screen.");
        return;
    }

    [self willPresentInterstitial];
    self.applicationHasStatusBar = !([UIApplication sharedApplication].isStatusBarHidden);
    [self setApplicationStatusBarHidden:YES];

    [self layoutCloseButton];
    if (!isPad()) {
         [controller mp_presentModalViewControllerSKZ:self animated:NO];
    } else {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
        [controller addChildViewController:self];
        [self.view rotateAccordingToStatusBarOrientationAndSupportedOrientations];
    }
    
}

- (void)willPresentInterstitial
{

}

- (void)didPresentInterstitial
{

}

- (void)willDismissInterstitial
{

}

- (void)didDismissInterstitial
{

}

- (BOOL)shouldDisplayCloseButton
{
    return YES;
}

#pragma mark - Close Button

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleBottomMargin;

        UIImage *closeButtonImage = [UIImage imageFromResource:kCloseButtonXImageName];
        [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
        [_closeButton sizeToFit];

        [_closeButton addTarget:self
                         action:@selector(closeButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
        _closeButton.accessibilityLabel = @"Close Interstitial Ad";
    }

    return _closeButton;
}

- (void)layoutCloseButton
{
    NSInteger padding = isPad() ? kCloseButtonPaddingForPad : kCloseButtonPadding;
    CGFloat originX = self.view.bounds.size.width - padding - self.closeButton.bounds.size.width;
    self.closeButton.frame = CGRectMake(originX,
                                        padding,
                                        self.closeButton.bounds.size.width,
                                        self.closeButton.bounds.size.height);
    [self setCloseButtonStyle:self.closeButtonStyle];
    [self.view addSubview:self.closeButton];
    [self.view bringSubviewToFront:self.closeButton];
}

- (void)setCloseButtonImageWithImageNamed:(NSString *)imageName
{
    UIImage *image = [UIImage imageFromResource:imageName];
    [self.closeButton setImage:image forState:UIControlStateNormal];
    [self.closeButton sizeToFit];
}

- (void)setCloseButtonStyle:(MPInterstitialCloseButtonStyle)style
{
    _closeButtonStyle = style;
    switch (style) {
        case MPInterstitialCloseButtonStyleAlwaysVisible:
            self.closeButton.hidden = NO;
            break;
        case MPInterstitialCloseButtonStyleAlwaysHidden:
            self.closeButton.hidden = YES;
            break;
        case MPInterstitialCloseButtonStyleAdControlled:
            self.closeButton.hidden = ![self shouldDisplayCloseButton];
            break;
        default:
            self.closeButton.hidden = NO;
            break;
    }
}

- (void)closeButtonPressed
{
    [self dismissInterstitialAnimated:YES];
}

- (void)dismissInterstitialAnimated:(BOOL)animated
{

    //If Skillz is shown, always reshow status bar. If not, base upon publisher's game.
    [self setApplicationStatusBarHidden:[[Skillz skillzInstance] sidepanelController] ? NO : self.applicationHasStatusBar];

    [self willDismissInterstitial];

    UIViewController *presentingViewController = [self mp_presentingViewControllerSKZ];
    // TODO: Is this check necessary?
    if ([presentingViewController mp_presentedViewControllerSKZ] == self) {
        [presentingViewController mp_dismissModalViewControllerAnimatedSKZ:MP_ANIMATED];
    } else {
        [UIView animateWithDuration:.3 animations:^{
            [self.view setAlpha:0];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    }

    [self didDismissInterstitial];
}

#pragma mark - Hidding status bar (pre-iOS 7)

- (void)setApplicationStatusBarHidden:(BOOL)hidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Hidding status bar (iOS 7 and above)

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Autorotation (iOS 6.0 and above)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger applicationSupportedOrientations = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:MPKeyWindow()];
    NSUInteger interstitialSupportedOrientations = applicationSupportedOrientations;
    NSString *orientationDescription = @"any";

    // Using the _orientationType, narrow down the supported interface orientations.

    if (_orientationType == MPInterstitialOrientationTypePortrait) {
        interstitialSupportedOrientations &=
        (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
        orientationDescription = @"portrait";
    }
    else if (_orientationType == MPInterstitialOrientationTypeLandscape) {
        interstitialSupportedOrientations &= UIInterfaceOrientationMaskLandscape;
        orientationDescription = @"landscape";
    }

    // If the application does not support any of the orientations given by _orientationType,
    // just return the application's supported orientations.

    if (!interstitialSupportedOrientations) {
        MPLogError(@"Your application does not support this interstitial's desired orientation "
                   @"(%@).", orientationDescription);
        return applicationSupportedOrientations;
    }
    else {
        return interstitialSupportedOrientations;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    NSUInteger supportedInterfaceOrientations = [self supportedInterfaceOrientations];
    UIInterfaceOrientation currentInterfaceOrientation = MPInterfaceOrientation();
    NSUInteger currentInterfaceOrientationMask = (1 << currentInterfaceOrientation);

    // First, try to display the interstitial using the current interface orientation. If the
    // current interface orientation is unsupported, just use any of the supported orientations.

    if (supportedInterfaceOrientations & currentInterfaceOrientationMask) {
        return currentInterfaceOrientation;
    }
    else if (supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
        return UIInterfaceOrientationPortrait;
    }
    else if (supportedInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown;
    }
    else if (supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    else {
        return UIInterfaceOrientationLandscapeRight;
    }
}
#endif

#pragma mark - Autorotation (before iOS 6.0)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (_orientationType == MPInterstitialOrientationTypePortrait)
        return (interfaceOrientation == UIInterfaceOrientationPortrait ||
                interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    else if (_orientationType == MPInterstitialOrientationTypeLandscape)
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    else return YES;
}

- (void)dealloc
{
    SKZLog(@"dealloc %@", self);
}

@end
