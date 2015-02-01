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

#import "SHAStructure.h"
#import "SHAUsageStatus.h"
#import "SHANestOperations.h"
#import "SHANotificationManager.h"

@interface SHANestOperations ()

@property (nonatomic, retain) SHANestStructureManager *nestStructureManager;

@property (nonatomic, retain) NSMutableArray *structures;
@property (nonatomic, retain) SHAUsageStatus *usageStatus;

@end

@implementation SHANestOperations

#pragma mark Initialization

+ (instancetype)sharedManager
{
	static SHANestOperations *sharedManager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [[SHANestOperations alloc] init];
	});

	return (sharedManager);
}

- (instancetype)init
{
	self = [super init];
	if (self == nil)
		return (nil);

	// Get the initial structure
	self.nestStructureManager = [[SHANestStructureManager alloc] init];
	[self.nestStructureManager setDelegate:self];
	[self.nestStructureManager initialize];

	self.usageStatus = [[SHAUsageStatus alloc] init];

	return (self);
}

#pragma mark - Home/Away Actions

- (void)setHomeForStructure:(SHAStructure *)structure
{
	NSLog(@"Setting \"%@\" to HOME (was %@)", structure.name, structure.away ? @"AWAY" : @"HOME");
	structure.away = NO;
	[self.nestStructureManager saveChangesForStructure:structure];
}

- (void)setHomeForStructureID:(NSString *)structureID
{
	for (SHAStructure *structure in self.structures) {
		if ([structure.structureID isEqualToString:structureID]) {
			[self setHomeForStructure:structure];
			break;
		}
	}
}

- (void)setAwayForStructure:(SHAStructure *)structure
{
	NSLog(@"Setting \"%@\" to AWAY (was %@)", structure.name, structure.away ? @"AWAY" : @"HOME");
	structure.away = YES;
	[self.nestStructureManager saveChangesForStructure:structure];
}

- (void)setAwayForStructureID:(NSString *)structureID
{
	for (SHAStructure *structure in self.structures) {
		if ([structure.structureID isEqualToString:structureID]) {
			[self setAwayForStructure:structure];
			break;
		}
	}
}

- (void)structureUpdated:(NSDictionary *)structure
{
	if (self.structures == nil) {
		self.structures = [@[] mutableCopy];
		for (NSString *key in structure) {
			SHAStructure *s = [[SHAStructure alloc] init];
			s.away = ![structure[key][@"away"] isEqualToString:@"home"];
			s.name = structure[key][@"name"];
			s.structureID = structure[key][@"structure_id"];
			[self.structures addObject:s];

			[self.nestStructureManager beginSubscriptionForStructure:s];
			NSLog(@"Began subscription for \"%@\" (%@)", s.name, s.structureID);
		}
	} else {
		for (NSString *key in structure) {
			NSString *sid = structure[key][@"structure_id"];
			for (SHAStructure *s in self.structures) {
				if ([s.structureID isEqualToString:sid]) {
					NSUInteger index = [self.structures indexOfObject:s];
					SHAStructure *updatedStructure = self.structures[index];

					updatedStructure.away = ![structure[key][@"away"] isEqualToString:@"home"];
					updatedStructure.name = structure[key][@"name"];
					updatedStructure.structureID = structure[key][@"structure_id"];
					NSLog(@"Processed update for structure %@ (%@)", updatedStructure.name, updatedStructure.structureID);

					if (self.usageStatus.active && updatedStructure.away) {
						/* 
						 * Sometimes we will get "mixed signals" if the screensaver is dismissed
						 * but the lock screen is never dismissed, so wait several seconds for the
						 * user to figure out their current state.
						 */
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
							if (!self.usageStatus.active)
								return;

							SHAStructure *notificationStructure = self.structures[index];
							NSLog(@"You're using the computer, but thermostat at %@ is away.", notificationStructure.name);
							[[SHANotificationManager sharedManager] showActiveButAwayNotificationForStructure:notificationStructure];
						});
					}
				}
			}
		}
	}
}


@end
