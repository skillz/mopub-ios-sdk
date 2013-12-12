//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRVideoPlayerManagerDelegateSKZ;

@interface MRVideoPlayerManagerSKZ : NSObject

@property (nonatomic, assign) id<MRVideoPlayerManagerDelegateSKZ> delegate;

- (id)initWithDelegate:(id<MRVideoPlayerManagerDelegateSKZ>)delegate;
- (void)playVideo:(NSDictionary *)parameters;

@end

@protocol MRVideoPlayerManagerDelegateSKZ <NSObject>

- (UIViewController *)viewControllerForPresentingVideoPlayer;
- (void)videoPlayerManagerWillPresentVideo:(MRVideoPlayerManagerSKZ *)manager;
- (void)videoPlayerManagerDidDismissVideo:(MRVideoPlayerManagerSKZ *)manager;
- (void)videoPlayerManager:(MRVideoPlayerManagerSKZ *)manager
        didFailToPlayVideoWithErrorMessage:(NSString *)message;

@end
