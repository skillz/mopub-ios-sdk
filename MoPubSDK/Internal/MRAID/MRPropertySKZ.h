//
//  MRProperty.h
//  MoPub
//
//  Created by Andrew He on 12/13/11.
//  Copyright (c) 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRAdViewSKZ.h"

@interface MRPropertySKZ : NSObject

- (NSString *)description;
- (NSString *)jsonString;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRPlacementTypePropertySKZ : MRPropertySKZ {
    MRAdViewPlacementType _placementType;
}

@property (nonatomic, assign) MRAdViewPlacementType placementType;

+ (MRPlacementTypePropertySKZ *)propertyWithType:(MRAdViewPlacementType)type;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRStatePropertySKZ : MRPropertySKZ {
    MRAdViewState _state;
}

@property (nonatomic, assign) MRAdViewState state;

+ (MRStatePropertySKZ *)propertyWithState:(MRAdViewState)state;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRScreenSizePropertySKZ : MRPropertySKZ {
    CGSize _screenSize;
}

@property (nonatomic, assign) CGSize screenSize;

+ (MRScreenSizePropertySKZ *)propertyWithSize:(CGSize)size;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRSupportsPropertySKZ : MRPropertySKZ

@property (nonatomic, assign) BOOL supportsSms;
@property (nonatomic, assign) BOOL supportsTel;
@property (nonatomic, assign) BOOL supportsCalendar;
@property (nonatomic, assign) BOOL supportsStorePicture;
@property (nonatomic, assign) BOOL supportsInlineVideo;

+ (NSDictionary *)supportedFeatures;
+ (MRSupportsPropertySKZ *)defaultProperty;
+ (MRSupportsPropertySKZ *)propertyWithSupportedFeaturesDictionary:(NSDictionary *)dictionary;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MRViewablePropertySKZ : MRPropertySKZ {
    BOOL _isViewable;
}

@property (nonatomic, assign) BOOL isViewable;

+ (MRViewablePropertySKZ *)propertyWithViewable:(BOOL)viewable;

@end
