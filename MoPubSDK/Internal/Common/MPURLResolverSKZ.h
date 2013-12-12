//
//  MPURLResolver.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPGlobal.h"

@protocol MPURLResolverDelegateSKZ;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
@interface MPURLResolverSKZ : NSObject <NSURLConnectionDataDelegate>
#else
@interface MPURLResolver : NSObject
#endif

@property (nonatomic, assign) id<MPURLResolverDelegateSKZ> delegate;

+ (MPURLResolverSKZ *)resolver;
- (void)startResolvingWithURL:(NSURL *)URL delegate:(id<MPURLResolverDelegateSKZ>)delegate;
- (void)cancel;

@end

@protocol MPURLResolverDelegateSKZ <NSObject>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL;
- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL;
- (void)openURLInApplication:(NSURL *)URL;
- (void)failedToResolveURLWithError:(NSError *)error;

@end
