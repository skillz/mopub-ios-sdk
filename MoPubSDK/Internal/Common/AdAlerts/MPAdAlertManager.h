//
//  MPAdAlertManager.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPGlobal.h"

@class CLLocation;
@protocol MPAdAlertManagerDelegate;

@class MPAdConfigurationSKZ;

@interface MPAdAlertManager : NSObject <MPAdAlertManagerProtocolSKZ>

@end

@protocol MPAdAlertManagerDelegate <NSObject>

@required
- (UIViewController *)viewControllerForPresentingMailVC;
- (void)adAlertManagerDidTriggerAlert:(MPAdAlertManager *)manager;

@optional
- (void)adAlertManagerDidProcessAlert:(MPAdAlertManager *)manager;

@end