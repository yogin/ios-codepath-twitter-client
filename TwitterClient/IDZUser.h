//
//  IDZUser.h
//  TwitterClient
//
//  Created by Anthony Powles on 25/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const UserDidLoginNotification;
extern NSString *const UserDidLogoutNotification;

@interface IDZUser : NSObject

@property (strong, nonatomic) NSString *description;
@property int userId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *profileUrl; // profile_image_url
@property (strong, nonatomic) NSString *screenName;

#pragma mark - Class Methods

+ (void)logout;
+ (IDZUser *)userFromJSON:(NSDictionary *)data;
+ (IDZUser *)currentUser;

#pragma mark - Instance Methods

- (IDZUser *)initFromJSON:(NSDictionary *)data;

@end
