//
//  SHAUsageStatus.m
//  Still Here
//
//  Created by Greg Fiumara on 1/19/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "SHAUsageStatus.h"

@implementation SHAUsageStatus

- (instancetype)init
{
	self = [super init];
	if (self == nil)
		return (nil);

	_active = YES;
	[self registerScreenEvents];

	return (self);
}

- (void)registerScreenEvents
{
	/* Screensaver */
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(processScreenDisabledWithNotification:) name:@"com.apple.screensaver.didstart" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(processScreenEnabledWithNotification:) name:@"com.apple.screensaver.didstop" object:nil];

	/* Lock */
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(processScreenDisabledWithNotification:) name:@"com.apple.screenIsLocked" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(processScreenEnabledWithNotification:) name:@"com.apple.screenIsUnlocked" object:nil];

	/* Sleep */
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(processScreenDisabledWithNotification:) name:NSWorkspaceWillSleepNotification object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(processScreenEnabledWithNotification:) name:NSWorkspaceDidWakeNotification object:nil];
}

#pragma mark - Notifications

- (void)processScreenDisabledWithNotification:(NSNotification *)notification
{
	@synchronized(self) {
		NSLog(@"Received %@, setting active = NO", notification.name);
		_active = NO;
	}
}

- (void)processScreenEnabledWithNotification:(NSNotification *)notification
{
	@synchronized(self) {
		NSLog(@"Received %@, setting active = YES", notification.name);
		_active = YES;
	}
}

- (void)dealloc
{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

@end
