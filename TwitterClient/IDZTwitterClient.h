//
//  IDZTwitterClient.h
//  TwitterClient
//
//  Created by Anthony Powles on 25/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BDBOAuth1Manager/BDBOAuth1SessionManager.h>

@interface IDZTwitterClient : NSObject

+ (IDZTwitterClient *)instance;
+ (BOOL)isAuthorized;

#pragma mark - OAuth

@property (nonatomic, readonly) BDBOAuth1SessionManager *networkManager;

- (void)authorize;
- (void)deauthorizeWithCompletion:(void (^)(void))completion;
- (BOOL)authorizationCallbackURL:(NSURL *)url onSuccess:(void (^)(void))completion;

@end
