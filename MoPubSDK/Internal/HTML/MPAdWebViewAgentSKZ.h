//
//  MPAdWebViewAgent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdDestinationDisplayAgentSKZ.h"

enum {
    MPAdWebViewEventAdDidAppear     = 0,
    MPAdWebViewEventAdDidDisappear  = 1
};
typedef NSUInteger MPAdWebViewEvent;

@protocol MPAdWebViewAgentDelegateSKZ;

@class MPAdConfigurationSKZ;
@class MPAdWebViewSKZ;
@class CLLocation;

@interface MPAdWebViewAgentSKZ : NSObject <UIWebViewDelegate, MPAdDestinationDisplayAgentDelegateSKZ>

@property (nonatomic, assign) id customMethodDelegate;
@property (nonatomic, retain) MPAdWebViewSKZ *view;
@property (nonatomic, assign) id<MPAdWebViewAgentDelegateSKZ> delegate;

- (id)initWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegateSKZ>)delegate customMethodDelegate:(id)customMethodDelegate;
- (void)loadConfiguration:(MPAdConfigurationSKZ *)configuration;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)invokeJavaScriptForEvent:(MPAdWebViewEvent)event;
- (void)forceRedraw;

- (void)stopHandlingRequests;
- (void)continueHandlingRequests;

@end

@class MPAdWebViewSKZ;

@protocol MPAdWebViewAgentDelegateSKZ <NSObject>

- (NSString *)adUnitId;
- (CLLocation *)location;
- (UIViewController *)viewControllerForPresentingModalView;
- (void)adDidClose:(MPAdWebViewSKZ *)ad;
- (void)adDidFinishLoadingAd:(MPAdWebViewSKZ *)ad;
- (void)adDidFailToLoadAd:(MPAdWebViewSKZ *)ad;
- (void)adActionWillBegin:(MPAdWebViewSKZ *)ad;
- (void)adActionWillLeaveApplication:(MPAdWebViewSKZ *)ad;
- (void)adActionDidFinish:(MPAdWebViewSKZ *)ad;

@end
