//
//  MPAnalyticsTracker.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAnalyticsTrackerSKZ.h"
#import "MPAdConfigurationSKZ.h"
#import "MPInstanceProviderSKZ.h"
#import "MPLogging.h"

@interface MPAnalyticsTrackerSKZ ()

- (NSURLRequest *)requestForURL:(NSURL *)URL;

@end

@implementation MPAnalyticsTrackerSKZ

+ (MPAnalyticsTrackerSKZ *)tracker
{
    return [[[MPAnalyticsTrackerSKZ alloc] init] autorelease];
}

- (void)trackImpressionForConfiguration:(MPAdConfigurationSKZ *)configuration
{
    MPLogDebug(@"Tracking impression: %@", configuration.impressionTrackingURL);
    [NSURLConnection connectionWithRequest:[self requestForURL:configuration.impressionTrackingURL]
                                  delegate:nil];
}

- (void)trackClickForConfiguration:(MPAdConfigurationSKZ *)configuration
{
    MPLogDebug(@"Tracking click: %@", configuration.clickTrackingURL);
    [NSURLConnection connectionWithRequest:[self requestForURL:configuration.clickTrackingURL]
                                  delegate:nil];
}

- (NSURLRequest *)requestForURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[MPInstanceProviderSKZ sharedProvider] buildConfiguredURLRequestWithURL:URL];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    return request;
}

@end
