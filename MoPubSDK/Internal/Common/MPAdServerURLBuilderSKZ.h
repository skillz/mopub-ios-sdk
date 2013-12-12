//
//  MPAdServerURLBuilder.h
//  MoPub
//
//  Copyright (c) 2012 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MPAdServerURLBuilderSKZ : NSObject

+ (NSURL *)URLWithAdUnitID:(NSString *)adUnitID
                  keywords:(NSString *)keywords
                  location:(CLLocation *)location
                   testing:(BOOL)testing;

@end
