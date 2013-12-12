//
//  MPAdRequestError.m
//  MoPub
//
//  Copyright (c) 2012 MoPub. All rights reserved.
//

#import "MPErrorSKZ.h"

NSString * const kMPErrorDomain = @"com.mopub.iossdk";

@implementation MPErrorSKZ

+ (MPErrorSKZ *)errorWithCode:(MPErrorCode)code
{
    return [self errorWithDomain:kMPErrorDomain code:code userInfo:nil];
}

@end
