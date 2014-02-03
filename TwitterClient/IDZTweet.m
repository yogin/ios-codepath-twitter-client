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
@property (strong, nonatomic, readwrite) NSString *text;
@property (strong, nonatomic, readwrite) NSDate *createdAt;
@property NSString *_elapsedCreatedAt;
@property NSString *_displayCreatedAt;

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
										   parameters:@{@"count": @(limit),
														@"include_my_retweet": @(YES)}
											  success:success
											  failure:failure];
}

+ (void)fetchNext:(int)limit until:(NSString *)maxId withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success andFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	[[[IDZTwitterClient instance] networkManager] GET:@"1.1/statuses/home_timeline.json"
										   parameters:@{@"count": @(limit),
														@"max_id": maxId,
														@"include_my_retweet": @(YES)}
											  success:success
											  failure:failure];
}

+ (IDZTweet *)updateStatus:(NSString *)status withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success andFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	[[[IDZTwitterClient instance] networkManager] POST:@"1.1/statuses/update.json"
											parameters:@{@"status": status}
											   success:success
											   failure:failure];

	return [[IDZTweet alloc] initWithStatus:status author:[IDZUser currentUser]];
}

+ (IDZTweet *)replyStatus:(NSString *)status toStatus:(NSString *)originalStatusId withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success andFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	[[[IDZTwitterClient instance] networkManager] POST:@"1.1/statuses/update.json"
											parameters:@{@"status": status,
														 @"in_reply_to_status_id": originalStatusId}
											   success:success
											   failure:failure];
	
	return [[IDZTweet alloc] initWithStatus:status author:[IDZUser currentUser]];
}

#pragma mark - Instance Methods

- (IDZTweet *)initFromJSON:(NSDictionary *)data
{
	self = [super init];
	if (self) {
//		NSLog(@"new tweet with: %@", data);
		self.rawTweet = data;
		
		NSDictionary *retweet = self.rawTweet[@"retweeted_status"];
		if (retweet) {
			self.retweeter = [IDZUser userFromJSON:data[@"user"]];
			self.author = [IDZUser userFromJSON:retweet[@"user"]];
			self.text = retweet[@"text"];
			self.createdAt = [self dateFromString:retweet[@"created_at"]];
		}
		else {
			self.author = [IDZUser userFromJSON:data[@"user"]];
			self.text = self.rawTweet[@"text"];
			self.createdAt = [self dateFromString:self.rawTweet[@"created_at"]];
		}
		
		self.favoriteCount = [self.rawTweet[@"favorite_count"] integerValue];
		self.isFavorite = [self.rawTweet[@"favorited"] boolValue];
		
		self.retweetCount = [self.rawTweet[@"retweet_count"] integerValue];
		self.isRetweeted = [self.rawTweet[@"retweeted"] boolValue];
		
		if (self.rawTweet[@"current_user_retweet"]) {
			self.retweetId = self.rawTweet[@"current_user_retweet"][@"id_str"];
		}
	}
	
	return self;
}

- (IDZTweet *)initWithStatus:(NSString *)status author:(IDZUser *)author
{
	self = [super init];
	if (self) {
		self.author = author;
		self.text = status;
		self.createdAt = [NSDate date];
	}
	
	return self;
}

- (NSString *)tweetId
{
	return self.rawTweet[@"id_str"];
}

- (BOOL)isRetweet
{
	return !!self.retweeter;
}

- (NSString *)elapsedCreatedAt
{
	if (!self._elapsedCreatedAt) {
		NSTimeInterval elapsedTimeInterval = [self.createdAt timeIntervalSinceNow];
		int elapsedSeconds = (int)(elapsedTimeInterval * -1);
	
		if (elapsedSeconds < 60) {
			self._elapsedCreatedAt = @"now";
		}
		else if (elapsedSeconds < 3600) {
			int minutes = elapsedSeconds / 60;
			self._elapsedCreatedAt = [NSString stringWithFormat:@"%dm", minutes];
		}
		else if (elapsedSeconds < 86400) {
			int hours = elapsedSeconds / 3600;
			self._elapsedCreatedAt = [NSString stringWithFormat:@"%dh", hours];
		}
		else if (elapsedSeconds < 31536000) {
			int days = elapsedSeconds / 86400;
			self._elapsedCreatedAt = [NSString stringWithFormat:@"%dd", days];
		}
		else {
			int years = elapsedSeconds / 31536000;
			self._elapsedCreatedAt = [NSString stringWithFormat:@"%dyr", years];
		}
	}
	
	return self._elapsedCreatedAt;
}

- (NSString *)displayCreatedAt
{
	if (!self._displayCreatedAt) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"M/d/yy, h:mm a"];
		self._displayCreatedAt = [formatter stringFromDate:self.createdAt];
	}
	
	return self._displayCreatedAt;
}

- (NSDate *)dateFromString:(NSString *)string
{
	// see http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
	return [formatter dateFromString:string];
}

- (void)addToFavorites
{
	if (!self.isFavorite) {
		self.isFavorite = YES;
		self.favoriteCount += 1;

		[[[IDZTwitterClient instance] networkManager] POST:@"1.1/favorites/create.json"
												parameters:@{@"id": self.tweetId}
												   success:nil
												   failure:^(NSURLSessionDataTask *task, NSError *error) {
													   self.favoriteCount -= 1;
													   self.isFavorite = NO;
												   }];
	}
}

- (void)removeFromFavorites
{
	if (self.isFavorite) {
		self.isFavorite = NO;
		self.favoriteCount -= 1;

		[[[IDZTwitterClient instance] networkManager] POST:@"1.1/favorites/destroy.json"
												parameters:@{@"id": self.tweetId}
												   success:nil
												   failure:^(NSURLSessionDataTask *task, NSError *error) {
													   self.favoriteCount += 1;
													   self.isFavorite = YES;
												   }];
	}
}

- (void)retweet
{
	if (!self.isRetweeted) {
		self.isRetweeted = YES;
		self.retweetCount += 1;
		
		NSString *url = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", self.tweetId];
		[[[IDZTwitterClient instance] networkManager] POST:url
												parameters:nil
												   success:^(NSURLSessionDataTask *task, id responseObject) {
													   self.retweetId = responseObject[@"id_str"];
												   }
												   failure:^(NSURLSessionDataTask *task, NSError *error) {
													   self.isRetweeted = NO;
													   self.retweetCount -= 1;
												   }];
	}
}

- (void)unretweet
{
	if (self.isRetweeted) {
		self.isRetweeted = NO;
		self.retweetCount -= 1;
		
		NSString *url = [NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", self.retweetId];
		[[[IDZTwitterClient instance] networkManager] POST:url
												parameters:nil
												   success:^(NSURLSessionDataTask *task, id responseObject) {
													   self.retweetId = nil;
												   }
												   failure:^(NSURLSessionDataTask *task, NSError *error) {
													   NSLog(@"unretweet error: %@", error);
													   self.isRetweeted = YES;
													   self.retweetCount += 1;
												   }];
	}
}

@end
