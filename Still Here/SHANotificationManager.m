/*
 * Copyright (c) 2015, Greg Fiumara
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of Greg Fiumara nor the names of its contributors may
 *   be used to endorse or promote products derived from this software without
 *   specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

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
