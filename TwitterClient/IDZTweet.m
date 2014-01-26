//
//  IDZTweet.m
//  TwitterClient
//
//  Created by Anthony Powles on 25/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import "IDZTweet.h"
#import "IDZTwitterClient.h"

@interface IDZTweet ()

@property (strong, nonatomic) NSDictionary *rawTweet;

@end

@implementation IDZTweet

#pragma mark - Class Methods

+ (IDZTweet *)tweetFromJSON:(NSDictionary *)data
{
	return [[IDZTweet alloc] initFromJSON:data];
}

+ (void)fetchLast:(int)limit withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success andFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	[[[IDZTwitterClient instance] networkManager] GET:@"1.1/statuses/home_timeline.json"
										   parameters:@{@"count": @(limit)}
											  success:success
											  failure:failure];
}

+ (void)fetchNext:(int)limit until:(NSString *)maxId withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success andFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	[[[IDZTwitterClient instance] networkManager] GET:@"1.1/statuses/home_timeline.json"
										   parameters:@{@"count": @(limit),
														@"max_id": maxId}
											  success:success
											  failure:failure];
}


#pragma mark - Instance Methods

- (IDZTweet *)initFromJSON:(NSDictionary *)data
{
	self = [super init];
	if (self) {
//		NSLog(@"new tweet with: %@", data);

		self.rawTweet = data;
		self.author = [IDZUser userFromJSON:data[@"user"]];
	}
	
	return self;
}

- (NSString *)tweetId
{
	return self.rawTweet[@"id_str"];
}

- (NSString *)text
{
	return self.rawTweet[@"text"];
}

@end
