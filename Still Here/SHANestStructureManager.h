//
//  SHANestStructureManager.h
//  Still Here
//
//  Created by Greg Fiumara on 1/19/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

@class SHAStructure;

@protocol SHANestStructureManagerDelegate

- (void)structureUpdated:(NSDictionary *)structure;

@end

@interface SHANestStructureManager : NSObject

@property (nonatomic, strong) id <SHANestStructureManagerDelegate>delegate;

- (void)initialize;
- (void)saveChangesForStructure:(SHAStructure *)structure;
- (void)beginSubscriptionForStructure:(SHAStructure *)structure;

@end
