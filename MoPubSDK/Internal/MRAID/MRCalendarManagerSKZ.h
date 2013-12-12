//
// Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKitUI/EventKitUI.h>

@protocol MRCalendarManagerDelegateSKZ;

@interface MRCalendarManagerSKZ : NSObject <EKEventEditViewDelegate>

@property (nonatomic, assign) NSObject<MRCalendarManagerDelegateSKZ> *delegate;

- (id)initWithDelegate:(NSObject<MRCalendarManagerDelegateSKZ> *)delegate;
- (void)createCalendarEventWithParameters:(NSDictionary *)parameters;

@end

@protocol MRCalendarManagerDelegateSKZ <NSObject>

@required
- (UIViewController *)viewControllerForPresentingCalendarEditor;
- (void)calendarManagerWillPresentCalendarEditor:(MRCalendarManagerSKZ *)manager;
- (void)calendarManagerDidDismissCalendarEditor:(MRCalendarManagerSKZ *)manager;
- (void)calendarManager:(MRCalendarManagerSKZ *)manager
        didFailToCreateCalendarEventWithErrorMessage:(NSString *)message;

@end
