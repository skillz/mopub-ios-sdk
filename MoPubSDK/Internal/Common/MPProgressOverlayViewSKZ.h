//
//  MPProgressOverlayView.h
//  MoPub
//
//  Created by Andrew He on 7/18/12.
//  Copyright 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPProgressOverlayViewDelegateSKZ;

@interface MPProgressOverlayViewSKZ : UIView {
    id<MPProgressOverlayViewDelegateSKZ> __weak _delegate;
    UIView *_outerContainer;
    UIView *_innerContainer;
    UIActivityIndicatorView *_activityIndicator;
    UIButton *_closeButton;
    CGPoint _closeButtonPortraitCenter;
}

@property (nonatomic, weak) id<MPProgressOverlayViewDelegateSKZ> delegate;
@property (nonatomic, strong) UIButton *closeButton;

- (id)initWithDelegate:(id<MPProgressOverlayViewDelegateSKZ>)delegate;
- (void)show;
- (void)hide;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPProgressOverlayViewDelegateSKZ <NSObject>

@optional
- (void)overlayCancelButtonPressed;
- (void)overlayDidAppear;

@end
