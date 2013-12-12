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
    id<MPProgressOverlayViewDelegateSKZ> _delegate;
    UIView *_outerContainer;
    UIView *_innerContainer;
    UIActivityIndicatorView *_activityIndicator;
    UIButton *_closeButton;
    CGPoint _closeButtonPortraitCenter;
}

@property (nonatomic, assign) id<MPProgressOverlayViewDelegateSKZ> delegate;
@property (nonatomic, retain) UIButton *closeButton;

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
