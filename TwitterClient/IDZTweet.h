//
//  IDZTweet.h
//  TwitterClient
//
//  Created by Anthony Powles on 25/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDZUser.h"

@interface IDZTweet : NSObject

@property (strong, nonatomic) IDZUser *retweeter;
@property (strong, nonatomic) IDZUser *author;
@property (strong, nonatomic, readonly) NSDate *createdAt;
@property (strong, nonatomic, readonly) NSString *text;


#pragma mark - Class Methods

+ (IDZTweet *)tweetFromJSON:(NSDictionary *)data;

+ (void)fetchLast:(int)limit withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success andFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)fetchNext:(int)limit until:(NSString *)maxId withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success andFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


#pragma mark - Instance Methods

- (IDZTweet *)initFromJSON:(NSDictionary *)data;
- (NSString *)tweetId;
- (NSString *)elapsedCreatedAt;

@end
