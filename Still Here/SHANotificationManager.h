//
//  SHANotificationManager.h
//  Still Here
//
//  Created by Greg Fiumara on 1/21/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

#import "SHAStructure.h"

#import <Foundation/Foundation.h>

@interface SHANotificationManager : NSObject <NSUserNotificationCenterDelegate>

+ (instancetype)sharedManager;
- (void)showActiveButAwayNotificationForStructure:(SHAStructure *)structure;
- (void)showStayingActiveNotificationForStructure:(SHAStructure *)structure;

@end
