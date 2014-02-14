//
//  MPAdServerCommunicator.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MPAdConfigurationSKZ.h"
#import "MPGlobal.h"

@protocol MPAdServerCommunicatorDelegateSKZ;

////////////////////////////////////////////////////////////////////////////////////////////////////

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
@interface MPAdServerCommunicatorSKZ : NSObject <NSURLConnectionDataDelegate>
#else
@interface MPAdServerCommunicator : NSObject
#endif

@property (nonatomic, weak) id<MPAdServerCommunicatorDelegateSKZ> delegate;
@property (nonatomic, assign, readonly) BOOL loading;

- (id)initWithDelegate:(id<MPAdServerCommunicatorDelegateSKZ>)delegate;

- (void)loadURL:(NSURL *)URL;
- (void)cancel;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPAdServerCommunicatorDelegateSKZ <NSObject>

@required
- (void)communicatorDidReceiveAdConfiguration:(MPAdConfigurationSKZ *)configuration;
- (void)communicatorDidFailWithError:(NSError *)error;

@end
