//
//  MPAdDestinationDisplayAgent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPURLResolverSKZ.h"
#import "MPProgressOverlayViewSKZ.h"
#import "MPAdBrowserControllerSKZ.h"
#import "MPStoreKitProviderSKZ.h"

@protocol MPAdDestinationDisplayAgentDelegateSKZ;

@interface MPAdDestinationDisplayAgentSKZ : NSObject <MPURLResolverDelegateSKZ, MPProgressOverlayViewDelegateSKZ, MPAdBrowserControllerDelegate, MPSKStoreProductViewControllerDelegate>

@property (nonatomic, weak) id<MPAdDestinationDisplayAgentDelegateSKZ> delegate;

+ (MPAdDestinationDisplayAgentSKZ *)agentWithDelegate:(id<MPAdDestinationDisplayAgentDelegateSKZ>)delegate;
- (void)displayDestinationForURL:(NSURL *)URL;
- (void)cancel;

@end

@protocol MPAdDestinationDisplayAgentDelegateSKZ <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;
- (void)displayAgentWillPresentModal;
- (void)displayAgentWillLeaveApplication;
- (void)displayAgentDidDismissModal;

@end
