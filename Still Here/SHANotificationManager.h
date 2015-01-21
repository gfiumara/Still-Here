//
//  SHANotificationManager.h
//  Still Here
//
//  Created by Greg Fiumara on 1/21/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

#import "Structure.h"

#import <Foundation/Foundation.h>

@interface SHANotificationManager : NSObject <NSUserNotificationCenterDelegate>

+ (instancetype)sharedManager;
- (void)showActiveButAwayNotificationForStructure:(Structure *)structure;
- (void)showStayingActiveNotificationForStructure:(Structure *)structure;

@end
