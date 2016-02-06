//
//  MPAdServerURLBuilder.m
//  MoPub
//
//  Copyright (c) 2012 MoPub. All rights reserved.
//

#import "MPAdServerURLBuilderSKZ.h"

#import "MPConstants.h"
#import "MPGlobal.h"
#import "MPKeywordProvider.h"
#import "MPIdentityProviderSKZ.h"
#import "MPInstanceProviderSKZ.h"
#import "MPReachabilitySKZ.h"

NSString * const kMoPubInterfaceOrientationPortrait = @"p";
NSString * const kMoPubInterfaceOrientationLandscape = @"l";

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPAdServerURLBuilderSKZ ()

+ (NSString *)queryParameterForKeywords:(NSString *)keywords;
+ (NSString *)queryParameterForOrientation;
+ (NSString *)queryParameterForScaleFactor;
+ (NSString *)queryParameterForTimeZone;
+ (NSString *)queryParameterForLocation:(CLLocation *)location;
+ (NSString *)queryParameterForMRAID;
+ (NSString *)queryParameterForDNT;
+ (NSString *)queryParameterForConnectionType;
+ (NSString *)queryParameterForApplicationVersion;
+ (NSString *)queryParameterForCarrierName;
+ (NSString *)queryParameterForISOCountryCode;
+ (NSString *)queryParameterForMobileNetworkCode;
+ (NSString *)queryParameterForMobileCountryCode;
+ (BOOL)advertisingTrackingEnabled;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPAdServerURLBuilderSKZ

+ (NSURL *)URLWithAdUnitID:(NSString *)adUnitID
                  keywords:(NSString *)keywords
                  location:(CLLocation *)location
                   testing:(BOOL)testing
{
    NSString *URLString = [NSString stringWithFormat:@"https://%@/m/ad?v=%@&udid=%@&id=%@&nv=%@",
                           testing ? HOSTNAME_FOR_TESTING : HOSTNAME,
                           MP_SERVER_VERSION,
                           [MPIdentityProviderSKZ identifier],
                           [adUnitID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                           MP_SDK_VERSION];

    URLString = [URLString stringByAppendingString:[self queryParameterForKeywords:keywords]];
    URLString = [URLString stringByAppendingString:[self queryParameterForOrientation]];
    URLString = [URLString stringByAppendingString:[self queryParameterForScaleFactor]];
    URLString = [URLString stringByAppendingString:[self queryParameterForTimeZone]];
    URLString = [URLString stringByAppendingString:[self queryParameterForLocation:location]];
    URLString = [URLString stringByAppendingString:[self queryParameterForMRAID]];
    URLString = [URLString stringByAppendingString:[self queryParameterForDNT]];
    URLString = [URLString stringByAppendingString:[self queryParameterForConnectionType]];
    URLString = [URLString stringByAppendingString:[self queryParameterForApplicationVersion]];
    URLString = [URLString stringByAppendingString:[self queryParameterForCarrierName]];
    URLString = [URLString stringByAppendingString:[self queryParameterForISOCountryCode]];
    URLString = [URLString stringByAppendingString:[self queryParameterForMobileNetworkCode]];
    URLString = [URLString stringByAppendingString:[self queryParameterForMobileCountryCode]];

    return [NSURL URLWithString:URLString];
}


+ (NSString *)queryParameterForKeywords:(NSString *)keywords
{
    NSMutableArray *keywordsArray = [NSMutableArray array];
    NSString *trimmedKeywords = [keywords stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
    if ([trimmedKeywords length] > 0) {
        [keywordsArray addObject:trimmedKeywords];
    }

    // Append the Facebook attribution keyword (if available).
    Class fbKeywordProviderClass = NSClassFromString(@"MPFacebookKeywordProviderSKZ");
    if ([fbKeywordProviderClass conformsToProtocol:@protocol(MPKeywordProviderSKZ)])
    {
        NSString *fbAttributionKeyword = [(Class<MPKeywordProviderSKZ>) fbKeywordProviderClass keyword];
        if ([fbAttributionKeyword length] > 0) {
            [keywordsArray addObject:fbAttributionKeyword];
        }
    }

    if ([keywordsArray count] == 0) {
        return @"";
    } else {
        NSString *keywords = [[keywordsArray componentsJoinedByString:@","]
                              stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"&q=%@", keywords];
    }
}

+ (NSString *)queryParameterForOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSString *orientString = UIInterfaceOrientationIsPortrait(orientation) ?
        kMoPubInterfaceOrientationPortrait : kMoPubInterfaceOrientationLandscape;
    return [NSString stringWithFormat:@"&o=%@", orientString];
}

+ (NSString *)queryParameterForScaleFactor
{
    return [NSString stringWithFormat:@"&sc=%.1f", MPDeviceScaleFactor()];
}

+ (NSString *)queryParameterForTimeZone
{
    static NSDateFormatter *formatter;
    @synchronized(self)
    {
        if (!formatter) formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateFormat:@"Z"];
    NSDate *today = [NSDate date];
    return [NSString stringWithFormat:@"&z=%@", [formatter stringFromDate:today]];
}

+ (NSString *)queryParameterForLocation:(CLLocation *)location
{
    NSString *result = @"";

    if (location && location.horizontalAccuracy >= 0) {
        result = [NSString stringWithFormat:@"&ll=%@,%@",
                  [NSNumber numberWithDouble:location.coordinate.latitude],
                  [NSNumber numberWithDouble:location.coordinate.longitude]];

        if (location.horizontalAccuracy) {
            result = [result stringByAppendingFormat:@"&lla=%@",
                      [NSNumber numberWithDouble:location.horizontalAccuracy]];
        }
    }

    return result;
}

+ (NSString *)queryParameterForMRAID
{
    if (NSClassFromString(@"MPMRAIDBannerCustomEventSKZ") &&
        NSClassFromString(@"MPMRAIDInterstitialCustomEventSKZ")) {
        return @"&mr=1";
    } else {
        return @"";
    }
}

+ (NSString *)queryParameterForDNT
{
    return [self advertisingTrackingEnabled] ? @"" : @"&dnt=1";
}

+ (NSString *)queryParameterForConnectionType
{
    return [[[MPInstanceProviderSKZ sharedProvider] sharedMPReachability] hasWifi] ? @"&ct=2" : @"&ct=3";
}

+ (NSString *)queryParameterForApplicationVersion
{
    NSString *applicationVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"&av=%@",
            [applicationVersion URLEncodedStringSKZ]];
}

+ (NSString *)queryParameterForCarrierName
{
    NSString *carrierName = [[[MPInstanceProviderSKZ sharedProvider] sharedCarrierInfo] objectForKey:@"carrierName"];
    return carrierName ? [NSString stringWithFormat:@"&cn=%@",
                          [carrierName URLEncodedStringSKZ]] : @"";
}

+ (NSString *)queryParameterForISOCountryCode
{
    NSString *code = [[[MPInstanceProviderSKZ sharedProvider] sharedCarrierInfo] objectForKey:@"isoCountryCode"];
    return code ? [NSString stringWithFormat:@"&iso=%@", [code URLEncodedStringSKZ]] : @"";
}

+ (NSString *)queryParameterForMobileNetworkCode
{
    NSString *code = [[[MPInstanceProviderSKZ sharedProvider] sharedCarrierInfo] objectForKey:@"mobileNetworkCode"];
    return code ? [NSString stringWithFormat:@"&mnc=%@", [code URLEncodedStringSKZ]] : @"";
}

+ (NSString *)queryParameterForMobileCountryCode
{
    NSString *code = [[[MPInstanceProviderSKZ sharedProvider] sharedCarrierInfo] objectForKey:@"mobileCountryCode"];
    return code ? [NSString stringWithFormat:@"&mcc=%@", [code URLEncodedStringSKZ]] : @"";
}

+ (BOOL)advertisingTrackingEnabled
{
    return [MPIdentityProviderSKZ advertisingTrackingEnabled];
}

@end
