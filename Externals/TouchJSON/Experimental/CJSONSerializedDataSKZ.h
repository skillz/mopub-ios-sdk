//
//  CJSONSerializedData.h
//  TouchJSON
//
//  Created by Jonathan Wight on 10/31/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CJSONSerializableSKZ <NSObject>
@property (readonly, nonatomic, retain) NSData *serializedJSONData;
@end

#pragma mark -

@interface CJSONSerializedDataSKZ : NSObject <CJSONSerializableSKZ> {
    NSData *data;
}

@property (readonly, nonatomic, retain) NSData *data;

- (id)initWithData:(NSData *)inData;

@end
