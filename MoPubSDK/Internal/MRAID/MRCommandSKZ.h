//
//  MRCommand.h
//  MoPub
//
//  Created by Andrew He on 12/19/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRAdViewSKZ.h"

@protocol MRCommandDelegateSKZ<NSObject>

@optional

- (void)didCreateCalendarEvent:(NSDictionary *)parameters;
- (void)playVideo:(NSDictionary *)parameters;
- (void)storePicture:(NSDictionary *)parameters;

@end

@interface MRAdViewSKZ (MRCommand)

@property (nonatomic, retain, readonly) MRAdViewDisplayControllerSKZ *displayController;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRCommandSKZ : NSObject {
    MRAdViewSKZ *_view;
    NSDictionary *_parameters;
}

@property (nonatomic, assign) id<MRCommandDelegateSKZ> delegate;
@property (nonatomic, assign) MRAdViewSKZ *view;
@property (nonatomic, retain) NSDictionary *parameters;

+ (NSMutableDictionary *)sharedCommandClassMap;
+ (void)registerCommand:(Class)commandClass;
+ (NSString *)commandType;
+ (id)commandForString:(NSString *)string;

- (BOOL)execute;

- (CGFloat)floatFromParametersForKey:(NSString *)key;
- (CGFloat)floatFromParametersForKey:(NSString *)key withDefault:(CGFloat)defaultValue;
- (BOOL)boolFromParametersForKey:(NSString *)key;
- (int)intFromParametersForKey:(NSString *)key;
- (NSString *)stringFromParametersForKey:(NSString *)key;
- (NSURL *)urlFromParametersForKey:(NSString *)key;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRCloseCommandSKZ : MRCommandSKZ
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRExpandCommandSKZ : MRCommandSKZ
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRUseCustomCloseCommandSKZ : MRCommandSKZ
@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MROpenCommandSKZ : MRCommandSKZ
@end
