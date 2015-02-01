//
//  NestAuthManager.m
//  Still Here
//
//  Created by Greg Fiumara on 2/1/15.
//  Copyright (c) 2015 Greg Fiumara. All rights reserved.
//

#import "NestAuthManager.h"

@implementation NestAuthManager

+ (instancetype)sharedManager
{
	static NestAuthManager *sharedManager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedManager = [NestAuthManager new];
	});
	return (sharedManager);
}

#pragma mark - Keychain

+ (NSDictionary *)attributesDictionary
{
	static NSMutableDictionary *attributes;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		attributes = [@{} mutableCopy];
		[attributes setObject:(__bridge id)(kSecClassGenericPassword) forKey:(__bridge id<NSCopying>)(kSecClass)];
		[attributes setObject:@"Nest OAuth2 Token" forKey:(__bridge id<NSCopying>)(kSecAttrLabel)];
		[attributes setObject:@"OAuth2 Token" forKey:(__bridge id<NSCopying>)(kSecAttrDescription)];
		[attributes setObject:@"Nest" forKey:(__bridge id<NSCopying>)(kSecAttrService)];
	});

	return (attributes);
}

- (NSString *)accessToken
{
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[NestAuthManager attributesDictionary]];
	[attributes setObject:(__bridge id)(kCFBooleanTrue) forKey:(__bridge id<NSCopying>)(kSecReturnData)];
	[attributes setObject:(__bridge id)(kSecMatchLimitOne) forKey:(__bridge id<NSCopying>)(kSecMatchLimit)];

	CFDataRef result = NULL;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(attributes), (CFTypeRef *)&result);
	if (status != 0) {
		if (result != NULL)
			CFRelease(result);
		return (nil);
	}
	if (result == NULL)
		return (nil);

	NSString *token = [[NSString alloc] initWithData:(__bridge NSData *)(result) encoding:NSUTF8StringEncoding];
	CFRelease(result);

	return (token);
}

- (BOOL)saveAccessToken:(NSString *)accessToken
{
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[NestAuthManager attributesDictionary]];
	[attributes setObject:[accessToken dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id<NSCopying>)(kSecValueData)];
	[attributes setObject:(__bridge id)(kSecAttrAccessibleWhenUnlocked) forKey:(__bridge id<NSCopying>)(kSecAttrAccessible)];

	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)(attributes), NULL);
	if (status != 0) {
		/* If duplicate detected, try remove/add */
		if (status == errSecDuplicateItem) {
			static BOOL loopCheck = NO;
			if (!loopCheck) {
				loopCheck = YES;
				[self removeAccessToken];
				return ([self saveAccessToken:accessToken]);
			}
		}
	}

	return (status == 0);
}

- (BOOL)removeAccessToken
{
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[NestAuthManager attributesDictionary]];
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)(attributes));
	return (status == 0);
}

@end
