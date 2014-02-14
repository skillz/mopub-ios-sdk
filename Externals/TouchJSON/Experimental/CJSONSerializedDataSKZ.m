//
//  CJSONSerializedData.m
//  TouchJSON
//
//  Created by Jonathan Wight on 10/31/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CJSONSerializedDataSKZ.h"

@interface CJSONSerializedDataSKZ ()
@end

#pragma mark -

@implementation CJSONSerializedDataSKZ

@synthesize data;

- (id)initWithData:(NSData *)inData
    {
    if ((self = [super init]) != NULL)
        {
        data = inData;
        }
    return(self);
    }


- (NSData *)serializedJSONData
    {
    return(self.data);
    }

@end
