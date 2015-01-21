//
//  SHANestOperations.m
//  Still Here
//
//  Created by Greg Fiumara on 1/19/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

#import "Structure.h"
#import "SHAUsageStatus.h"
#import "SHANestOperations.h"
#import "SHANotificationManager.h"

@interface SHANestOperations ()

@property (nonatomic, retain) NestStructureManager *nestStructureManager;

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
	self.nestStructureManager = [[NestStructureManager alloc] init];
	[self.nestStructureManager setDelegate:self];
	[self.nestStructureManager initialize];

	self.usageStatus = [[SHAUsageStatus alloc] init];

	return (self);
}

#pragma mark - Home/Away Actions

- (void)setHomeForStructure:(Structure *)structure
{
	NSLog(@"Setting \"%@\" to HOME (was %@)", structure.name, structure.away ? @"AWAY" : @"HOME");
	structure.away = NO;
	[self.nestStructureManager saveChangesForStructure:structure];
}

- (void)setHomeForStructureID:(NSString *)structureID
{
	for (Structure *structure in self.structures) {
		if ([structure.structureID isEqualToString:structureID]) {
			[self setHomeForStructure:structure];
			break;
		}
	}
}

- (void)setAwayForStructure:(Structure *)structure
{
	NSLog(@"Setting \"%@\" to AWAY (was %@)", structure.name, structure.away ? @"AWAY" : @"HOME");
	structure.away = YES;
	[self.nestStructureManager saveChangesForStructure:structure];
}

- (void)setAwayForStructureID:(NSString *)structureID
{
	for (Structure *structure in self.structures) {
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
			Structure *s = [[Structure alloc] init];
			s.away = ![structure[key][@"away"] isEqualToString:@"home"];
			s.name = structure[key][@"name"];
			s.structureID = structure[key][@"structure_id"];
			[self.structures addObject:s];

			[self.nestStructureManager beginSubscriptionForStructure:s];
			NSLog(@"Began subscription for \"%@\" (%@)", s.name, s.structureID);

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

				[[SHANotificationManager sharedManager] showActiveButAwayNotificationForStructure:s];
			});
		}
	} else {
		for (NSString *key in structure) {
			NSString *sid = structure[key][@"structure_id"];
			for (Structure *s in self.structures) {
				if ([s.structureID isEqualToString:sid]) {
					NSUInteger index = [self.structures indexOfObject:s];
					Structure *updatedStructure = self.structures[index];

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

							Structure *notificationStructure = self.structures[index];
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
