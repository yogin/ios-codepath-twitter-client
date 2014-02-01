//
//  IDZUser.m
//  TwitterClient
//
//  Created by Anthony Powles on 25/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import "IDZUser.h"
#import "IDZTwitterClient.h"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@implementation IDZUser

#pragma mark - Class Methods

+ (void)logout
{
	[[[IDZTwitterClient instance] networkManager] deauthorize];
	[[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

+ (IDZUser *)userFromJSON:(NSDictionary *)data
{
	static dispatch_once_t once;
    static NSMutableDictionary *users;
    
    dispatch_once(&once, ^{
        users = [[NSMutableDictionary alloc] init];
    });

	IDZUser *user = [users objectForKey:data[@"id"]];

	if (!user) {
		user = [[IDZUser alloc] initFromJSON:data];
		[users setObject:user forKey:@(user.userId)];
	}

	return user;
}

+ (IDZUser *)currentUser
{
	static dispatch_once_t once;
	static IDZUser *user;

	dispatch_once(&once, ^{
        user = [[IDZUser alloc] init];
    });

	if (!user.userId) {
		[[[IDZTwitterClient instance] networkManager] GET:@"1.1/account/verify_credentials.json"
											   parameters:nil
												  success:^(NSURLSessionDataTask *task, id responseObject) {
													  [user updateFromJSON:responseObject];
												  }
												  failure:^(NSURLSessionDataTask *task, NSError *error) {
													  // TODO
												  }];
	}

	return user;
}

#pragma mark - Instance Methods

- (IDZUser *)initFromJSON:(NSDictionary *)data
{
	self = [super init];
	if (self) {
		[self updateFromJSON:data];
	}
	
	return self;
}

- (void)updateFromJSON:(NSDictionary *)data
{
	self.description = data[@"description"];
	self.userId = (int)data[@"id"];
	self.name = data[@"name"];
	self.screenName = data[@"screen_name"];
	self.profileUrl = data[@"profile_image_url"];
}

@end
