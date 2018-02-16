//
//  MPInterstitialViewController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialViewController.h"

#import "MPGlobal.h"
#import "MPLogging.h"
#import "UIButton+MPAdditions.h"
#import "UIApplication+Skillz.h"
#import "UIView+Skillz.h"

static const CGFloat kCloseButtonPadding = 5.0;
static const CGFloat kCloseButtonEdgeInset = 5.0;
static const CGFloat kCloseButtonPaddingForPad = 12.0;
static NSString * const kCloseButtonXImageName = @"MPCloseButtonX.png";

@interface MPInterstitialViewController ()

@property (nonatomic, assign) BOOL applicationHasStatusBar;

- (void)setCloseButtonImageWithImageNamed:(NSString *)imageName;
- (void)setCloseButtonStyle:(MPInterstitialCloseButtonStyle)style;
- (void)closeButtonPressed;
- (void)dismissInterstitialAnimated:(BOOL)animated;
- (void)setApplicationStatusBarHidden:(BOOL)hidden;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPInterstitialViewController

@synthesize closeButton = _closeButton;
@synthesize closeButtonStyle = _closeButtonStyle;
@synthesize orientationType = _orientationType;
@synthesize applicationHasStatusBar = _applicationHasStatusBar;
@synthesize delegate = _delegate;


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - Public

- (void)presentInterstitialFromViewController:(UIViewController *)controller
{
    if (self.presentingViewController) {
        MPLogWarn(@"Cannot present an interstitial that is already on-screen.");
        return;
    }

    [self willPresentInterstitial];

    self.applicationHasStatusBar = !([UIApplication sharedApplication].isStatusBarHidden);
    [self setApplicationStatusBarHidden:YES];

    [self layoutCloseButton];

    if (!isPad()) {
        [controller presentViewController:self animated:NO completion:^{
            [self didPresentInterstitial];
        }];
    } else {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
        [controller addChildViewController:self];
        [self.view rotateAccordingToStatusBarOrientationAndSupportedOrientations];
        [self didPresentInterstitial];
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

        UIImage *closeButtonImage = [UIImage imageFromResource:MPResourcePathForResource(kCloseButtonXImageName)];
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
    [self.view addSubview:self.closeButton];
    NSInteger padding = isPad() ? kCloseButtonPaddingForPad : kCloseButtonPadding;
    CGFloat originX = self.view.bounds.size.width - padding - self.closeButton.bounds.size.width;
    self.closeButton.frame = CGRectMake(originX,
                                        padding,
                                        self.closeButton.bounds.size.width,
                                        self.closeButton.bounds.size.height);
    self.closeButton.mp_TouchAreaInsets = UIEdgeInsetsMake(kCloseButtonEdgeInset, kCloseButtonEdgeInset, kCloseButtonEdgeInset, kCloseButtonEdgeInset);
    [self setCloseButtonStyle:self.closeButtonStyle];
    if (@available(iOS 11.0, *)) {
        self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
                                                  [self.closeButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:padding],
                                                  [self.closeButton.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-padding],
                                                  ]];
    }
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
    [self setApplicationStatusBarHidden:!self.applicationHasStatusBar];

    [self willDismissInterstitial];

    UIViewController *presentingViewController = self.presentingViewController;
    // TODO: Is this check necessary?
    if (presentingViewController.presentedViewController == self) {
        [presentingViewController dismissViewControllerAnimated:MP_ANIMATED completion:^{
            [self didDismissInterstitial];
        }];
    } else {
        [UIView animateWithDuration:.3 animations:^{
            [self.view setAlpha:0];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [self didDismissInterstitial];
        }];
    }
}

#pragma mark - Hidding status bar (pre-iOS 7)

- (void)setApplicationStatusBarHidden:(BOOL)hidden
{
    [[UIApplication sharedApplication] mp_preIOS7setApplicationStatusBarHidden:hidden];
}

#pragma mark - Hidding status bar (iOS 7 and above)

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Autorotation (iOS 6.0 and above)

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if ([[NSUserDefaults gameOrientation] isEqualToString:SKZ_LANDSCAPE_ORIENTATION]) {
        return [[[[UIApplication sharedApplication] reliableKeyWindow] rootViewController] preferredInterfaceOrientationForPresentation];
    } else {
        return UIInterfaceOrientationPortrait;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[NSUserDefaults gameOrientation] isEqualToString:SKZ_LANDSCAPE_ORIENTATION]) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}
#pragma mark - Autorotation (before iOS 6.0)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[NSUserDefaults gameOrientation] isEqualToString:SKZ_LANDSCAPE_ORIENTATION]) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    }
}

@end
