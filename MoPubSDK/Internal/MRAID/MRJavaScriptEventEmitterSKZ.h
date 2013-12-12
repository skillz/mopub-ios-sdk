//
//  MRJavaScriptEventEmitter.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MRPropertySKZ;

@interface MRJavaScriptEventEmitterSKZ : NSObject

- (id)initWithWebView:(UIWebView *)webView;
- (NSString *)executeJavascript:(NSString *)javascript, ...;
- (void)fireChangeEventForProperty:(MRPropertySKZ *)property;
- (void)fireChangeEventsForProperties:(NSArray *)properties;
- (void)fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message;
- (void)fireReadyEvent;
- (void)fireNativeCommandCompleteEvent:(NSString *)command;

@end
