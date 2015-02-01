//
//  SHANestStructureManager.m
//  Still Here
//
//  Created by Greg Fiumara on 1/19/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

#import "SHANestStructureManager.h"
#import "SHAStructure.h"
#import "FirebaseManager.h"

@implementation SHANestStructureManager

/**
 * Gets the entire structure and converts it to
 * thermostat objects andreturns it as a dictionary.
 */
- (void)initialize
{
    [[FirebaseManager sharedManager] addSubscriptionToURL:@"structures/" withBlock:^(FDataSnapshot *snapshot) {
        [self parseStructure:snapshot.value];
    }];
}

/**
 * Parse the structure and send it back to the delegate
 * @param The structure you want to parse.
 */
- (void)parseStructure:(NSDictionary *)structure
{
	NSMutableDictionary *returnStructure = [[NSMutableDictionary alloc] init];

	for (NSString *key in structure) {
		returnStructure[key] = [@{} mutableCopy];

		returnStructure[key][@"away"] = structure[key][@"away"];
		returnStructure[key][@"name"] = structure[key][@"name"];
		returnStructure[key][@"structure_id"] = structure[key][@"structure_id"];
	}

	[self.delegate structureUpdated:returnStructure];
}

- (void)beginSubscriptionForStructure:(SHAStructure *)structure
{
	[[FirebaseManager sharedManager] addSubscriptionToURL:[NSString stringWithFormat:@"structures/%@/", structure.structureID]
						    withBlock:^(FDataSnapshot *snapshot) { [self updateStructure:snapshot.value]; }];
}

- (void)updateStructure:(NSDictionary *)structureJSON
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)saveChangesForStructure:(SHAStructure *)structure
{
	NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
	if (structure.away)
		[values setValue:@"away" forKey:@"away"];
	else
		[values setValue:@"home" forKey:@"away"];

	[[FirebaseManager sharedManager] setValues:values forURL:[NSString stringWithFormat:@"structures/%@/", structure.structureID]];
}

@end
