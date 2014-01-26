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

+ (void)fetchLast:(int)limit withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success andFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
//	NSString *url = [NSString stringWithFormat:@"statuses/home_timeline.json?count=%d", limit];
	[[[IDZTwitterClient instance] networkManager] GET:@"1.1/statuses/home_timeline.json"
										   parameters:@{@"count": @(limit)}
											  success:success
											  failure:failure];
}

+ (IDZTweet *)tweetFromJSON:(NSDictionary *)data
{
	return [[IDZTweet alloc] initFromJSON:data];
}

#pragma mark - Instance Methods

- (IDZTweet *)initFromJSON:(NSDictionary *)data
{
	self = [super init];
	if (self) {
		NSLog(@"new tweet with: %@", data);

		self.rawTweet = data;
		self.author = [IDZUser userFromJSON:data[@"user"]];
	}
	
	return self;
}

- (NSString *)text
{
	return self.rawTweet[@"text"];
}

@end
