//
//  IDZTwitterClient.m
//  TwitterClient
//
//  Created by Anthony Powles on 25/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import "IDZTwitterClient.h"
#import <BDBOAuth1Manager/NSDictionary+BDBOAuth1Manager.h>
#import "IDZUser.h"

#define TWITTER_BASE_URL [NSURL URLWithString:@"https://api.twitter.com/"]

#define TWITTER_CONSUMER_KEY @"GH7FU0AemrboNrOgcsVeTQ"
#define TWITTER_CONSUMER_SECRET @"9OTdKBiifxjOddUmP3IabYsTilp2ehoatN8iGrrWXw"

@interface IDZTwitterClient ()

@property (nonatomic, readwrite) BDBOAuth1SessionManager *networkManager;

@end

@implementation IDZTwitterClient

#pragma mark - Class Methods

+ (IDZTwitterClient *)instance
{
    static dispatch_once_t once;
    static IDZTwitterClient *instance;
    
    dispatch_once(&once, ^{
        instance = [[IDZTwitterClient alloc] init];
    });
    
    return instance;
}

+ (BOOL)isAuthorized
{
	return [[[IDZTwitterClient instance] networkManager] isAuthorized];
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        self.networkManager = [[BDBOAuth1SessionManager alloc] initWithBaseURL:TWITTER_BASE_URL
																   consumerKey:TWITTER_CONSUMER_KEY
																consumerSecret:TWITTER_CONSUMER_SECRET];
    }

    return self;
}


#pragma mark - OAuth Authorization

- (void)authorize
{
    [self.networkManager fetchRequestTokenWithPath:@"/oauth/request_token"
                                            method:@"POST"
                                       callbackURL:[NSURL URLWithString:@"idz-twitter-client://request"]
                                             scope:nil
                                           success:^(BDBOAuthToken *requestToken) {
											   NSLog(@"request token %@", requestToken);
											   
                                               NSString *authURL = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token];
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
                                           }
                                           failure:^(NSError *error) {
                                               NSLog(@"Error: %@", error.localizedDescription);
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                               message:@"!Could not acquire OAuth request token. Please try again later."
                                                                              delegate:self
                                                                     cancelButtonTitle:@"Dismiss"
                                                                     otherButtonTitles:nil] show];
                                               });
                                           }];
}

- (void)deauthorizeWithCompletion:(void (^)(void))completion
{
    [self.networkManager deauthorize];

    if (completion) {
        completion();
	}
}

- (BOOL)authorizationCallbackURL:(NSURL *)url onSuccess:(void (^)(void))completion
{
	if ([url.scheme isEqualToString:@"idz-twitter-client"]) {
		if ([url.host isEqualToString:@"request"])	{
			NSDictionary *parameters = [NSDictionary dictionaryFromQueryString:url.query];
			if (parameters[@"oauth_token"] && parameters[@"oauth_verifier"]) {
				[self.networkManager fetchAccessTokenWithPath:@"/oauth/access_token"
													   method:@"POST"
												 requestToken:[BDBOAuthToken tokenWithQueryString:url.query]
													  success:^(BDBOAuthToken *accessToken) {
														  NSLog(@"access token %@", accessToken);
														  [self.networkManager.requestSerializer saveAccessToken:accessToken];
														  [IDZUser currentUser];

														  if (completion) {
															  dispatch_async(dispatch_get_main_queue(), ^{
																completion();
															  });
														  }
													  }
													  failure:^(NSError *error) {
														  NSLog(@"Error: %@", error.localizedDescription);
														  dispatch_async(dispatch_get_main_queue(), ^{
															  [[[UIAlertView alloc] initWithTitle:@"Error"
																						  message:@"!!Could not acquire OAuth access token. Please try again later."
																						 delegate:self
																				cancelButtonTitle:@"Dismiss"
																				otherButtonTitles:nil] show];
														  });
													  }];
			}
		}

		return YES;
	}

	return NO;
}

@end
