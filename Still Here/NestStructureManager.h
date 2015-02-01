//
//  NestStructureManager.h
//  Still Here
//
//  Created by Greg Fiumara on 1/19/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

@class SHAStructure;

@protocol NestStructureManagerDelegate

- (void)structureUpdated:(NSDictionary *)structure;

@end

@interface NestStructureManager : NSObject

@property (nonatomic, strong) id <NestStructureManagerDelegate>delegate;

- (void)initialize;
- (void)saveChangesForStructure:(SHAStructure *)structure;
- (void)beginSubscriptionForStructure:(SHAStructure *)structure;

@end
