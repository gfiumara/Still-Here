//
//  NestAuthManager.h
//  Still Here
//
//  Created by Greg Fiumara on 2/1/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief
 * NOT the NestAuthManager from NestDK, but use a similar object that interacts
 * with the keychain.
 */
@interface NestAuthManager : NSObject

+ (instancetype)sharedManager;

@property (readonly) NSString *accessToken;

- (BOOL)saveAccessToken:(NSString *)accessToken;
- (BOOL)removeAccessToken;

@end
