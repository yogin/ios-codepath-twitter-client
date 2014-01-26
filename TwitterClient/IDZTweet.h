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

@property (strong, nonatomic) IDZUser *author;

#pragma mark - Class Methods

+ (void)fetchLast:(int)limit withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success andFailure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
+ (IDZTweet *)tweetFromJSON:(NSDictionary *)data;

#pragma mark - Instance Methods

- (IDZTweet *)initFromJSON:(NSDictionary *)data;
- (NSString *)text;

@end
