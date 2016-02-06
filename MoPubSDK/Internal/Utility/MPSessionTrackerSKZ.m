//
//  MPSessionTracker.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSessionTrackerSKZ.h"
#import "MPConstants.h"
#import "MPIdentityProviderSKZ.h"
#import "MPGlobal.h"
#import "MPInstanceProviderSKZ.h"

@implementation MPSessionTrackerSKZ

+ (void)load
{
    if (SESSION_TRACKING_ENABLED) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackEvent)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(trackEvent)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
}

+ (void)trackEvent
{
    [NSURLConnection connectionWithRequest:[[MPInstanceProviderSKZ sharedProvider] buildConfiguredURLRequestWithURL:[self URL]]
                                  delegate:nil];
}

+ (NSURL *)URL
{
    NSString *path = [NSString stringWithFormat:@"https://%@/m/open?v=%@&udid=%@&id=%@&av=%@&st=1",
                      HOSTNAME,
                      MP_SERVER_VERSION,
                      [MPIdentityProviderSKZ identifier],
                      [[[NSBundle mainBundle] bundleIdentifier] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                      ];

    return [NSURL URLWithString:path];
}

@end
