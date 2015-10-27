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
@protocol MPAdAlertManagerDelegateSKZ;

@class MPAdConfigurationSKZ;

@interface MPAdAlertManagerSKZ : NSObject <MPAdAlertManagerProtocolSKZ>

@end

@protocol MPAdAlertManagerDelegateSKZ <NSObject>

@required
- (UIViewController *)viewControllerForPresentingMailVC;
- (void)adAlertManagerDidTriggerAlert:(MPAdAlertManagerSKZ *)manager;

@optional
- (void)adAlertManagerDidProcessAlert:(MPAdAlertManagerSKZ *)manager;

@end