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
