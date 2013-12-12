//
//  UIViewController+MPAdditions.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MPAdditions)

/*
 * Returns the view controller that is being presented by this view controller.
 */
- (UIViewController *)mp_presentedViewControllerSKZ;

/*
 * Returns the view controller that presented this view controller.
 */
- (UIViewController *)mp_presentingViewControllerSKZ;

/*
 * Presents a view controller.
 */
- (void)mp_presentModalViewControllerSKZ:(UIViewController *)modalViewController
                             animated:(BOOL)animated;

/*
 * Dismisses a view controller.
 */
- (void)mp_dismissModalViewControllerAnimatedSKZ:(BOOL)animated;

@end
