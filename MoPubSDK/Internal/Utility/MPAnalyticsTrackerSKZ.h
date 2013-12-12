//
//  MPAnalyticsTracker.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAdConfigurationSKZ;

@interface MPAnalyticsTrackerSKZ : NSObject

+ (MPAnalyticsTrackerSKZ *)tracker;

- (void)trackImpressionForConfiguration:(MPAdConfigurationSKZ *)configuration;
- (void)trackClickForConfiguration:(MPAdConfigurationSKZ *)configuration;

@end
