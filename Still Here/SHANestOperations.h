//
//  SHANestOperations.h
//  Still Here
//
//  Created by Greg Fiumara on 1/19/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//
#import "NestStructureManager.h"

#import <Foundation/Foundation.h>

@interface SHANestOperations : NSObject <NestStructureManagerDelegate>

+ (instancetype)sharedManager;

- (void)setHomeForStructure:(Structure *)structure;
- (void)setHomeForStructureID:(NSString *)structureID;
- (void)setAwayForStructure:(Structure *)structure;
- (void)setAwayForStructureID:(NSString *)structureID;

@end
