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
