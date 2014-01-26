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
	return [[IDZUser alloc] initFromJSON:data];
}

#pragma mark - Instance Methods

- (IDZUser *)initFromJSON:(NSDictionary *)data
{
	self = [super init];
	if (self) {
		self.description = data[@"description"];
		self.userId = (int)data[@"id"];
		self.name = data[@"name"];
		self.screenName = data[@"screen_name"];
		self.profileUrl = data[@"profile_image_url"];
	}
	
	return self;
}

@end
