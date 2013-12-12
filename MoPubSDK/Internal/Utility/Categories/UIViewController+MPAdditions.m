//
//  UIViewController+MPAdditions.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "UIViewController+MPAdditions.h"

#import "MPGlobal.h"

@implementation UIViewController (MPAdditions)

- (UIViewController *)mp_presentedViewControllerSKZ
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
    if ([self respondsToSelector:@selector(presentedViewController)]) {
        // For iOS 5 and above.
        return self.presentedViewController;
    }
#endif
    // Prior to iOS 5, the parentViewController property holds the presenting view controller.
    return self.parentViewController;
}

- (UIViewController *)mp_presentingViewControllerSKZ
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        // For iOS 5 and above.
        return self.presentingViewController;
    } else {
        // Prior to iOS 5, the parentViewController property holds the presenting view controller.
        return self.parentViewController;
    }
#endif
    return self.parentViewController;
}

- (void)mp_presentModalViewControllerSKZ:(UIViewController *)modalViewController
                             animated:(BOOL)animated
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        [self presentViewController:modalViewController animated:animated completion:nil];
    }
#else
    [self presentModalViewController:modalViewController animated:animated];
#endif
}

- (void)mp_dismissModalViewControllerAnimatedSKZ:(BOOL)animated
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:animated completion:nil];
        return;
    }
#else
    [self dismissModalViewControllerAnimated:animated];
#endif
}

@end
