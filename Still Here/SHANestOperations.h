//
//  SHANestOperations.h
//  Still Here
//
//  Created by Greg Fiumara on 1/19/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//
#import "SHANestStructureManager.h"

#import <Foundation/Foundation.h>

@interface SHANestOperations : NSObject <SHANestStructureManagerDelegate>

+ (instancetype)sharedManager;

- (void)setHomeForStructure:(SHAStructure *)structure;
- (void)setHomeForStructureID:(NSString *)structureID;
- (void)setAwayForStructure:(SHAStructure *)structure;
- (void)setAwayForStructureID:(NSString *)structureID;

@end
