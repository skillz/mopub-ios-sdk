//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRImageDownloaderSKZ.h"

@protocol MRPictureManagerDelegateSKZ;

@interface MRPictureManagerSKZ : NSObject <UIAlertViewDelegate, MRImageDownloaderDelegateSKZ>

@property (nonatomic, weak) id<MRPictureManagerDelegateSKZ> delegate;

- (id)initWithDelegate:(id<MRPictureManagerDelegateSKZ>)delegate;
- (void)storePicture:(NSDictionary *)parameters;

@end

@protocol MRPictureManagerDelegateSKZ <NSObject>

@required
- (void)pictureManager:(MRPictureManagerSKZ *)manager
        didFailToStorePictureWithErrorMessage:(NSString *)message;

@end
