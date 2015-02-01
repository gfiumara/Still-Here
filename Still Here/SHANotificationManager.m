//
//  SHANotificationManager.m
//  Still Here
//
//  Created by Greg Fiumara on 1/21/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

#import "SHANestOperations.h"

#import "SHANotificationManager.h"

@interface SHANotificationManager()

@property (nonatomic, retain) NSMutableArray *timers;

@end

@implementation SHANotificationManager

+ (instancetype)sharedManager
{
	static SHANotificationManager *sharedManager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [SHANotificationManager new];
		sharedManager.timers = [@[] mutableCopy];
		[NSUserNotificationCenter defaultUserNotificationCenter].delegate = sharedManager;
	});
	return (sharedManager);
}

- (void)showActiveButAwayNotificationForStructure:(SHAStructure *)structure
{
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = [NSString stringWithFormat:@"%@ \"%@\"", NSLocalizedString(@"Away from", nil), structure.name];
	notification.informativeText = NSLocalizedString(@"No activity has been detected, but your computer screen is on.", nil);
	notification.identifier = structure.structureID;
	notification.hasActionButton = YES;
	notification.actionButtonTitle = NSLocalizedString(@"Away", nil);
	notification.otherButtonTitle = NSLocalizedString(@"Home", nil);

	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

	[self.timers addObject:[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(homeAwayTimerExpired:) userInfo:@{@"structure" : structure} repeats:NO]];
}

- (void)showStayingActiveNotificationForStructure:(SHAStructure *)structure
{
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = NSLocalizedString(@"Keeping Thermostats Active", nil);
	notification.informativeText = [NSString stringWithFormat:@"%@ \"%@.\"", NSLocalizedString(@"Automatically setting status to home at", nil), structure.name];
	notification.identifier = structure.structureID;
	notification.hasActionButton = YES;
	notification.actionButtonTitle = NSLocalizedString(@"Away", nil);

	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
	/* 
	 * We will keep the HVAC running by default. Only action to take is to
	 * mark the user as "away" from the structure.
	 */
	if (notification.activationType == NSUserNotificationActivationTypeActionButtonClicked) {
//		/* TODO: Set to "away" or let thermostat determine auto-away? */
//		[[SHANestOperations sharedManager] setAwayForStructureID:notification.identifier];

		/* Invalidate and remove auto-"home" timer */
		NSTimer *deletedTimer;
		for (NSTimer *timer in self.timers) {
			if ([((SHAStructure *)timer.userInfo[@"structure"]).structureID isEqualToString:notification.identifier]) {
				deletedTimer = timer;
				[timer invalidate];
				break;
			}
		}
		if (deletedTimer != nil)
			[self.timers removeObject:deletedTimer];
	}
}

- (void)homeAwayTimerExpired:(NSTimer *)timer
{
	[self showStayingActiveNotificationForStructure:timer.userInfo[@"structure"]];
	[[SHANestOperations sharedManager] setHomeForStructure:timer.userInfo[@"structure"]];
	[self.timers removeObject:timer];
}

@end
