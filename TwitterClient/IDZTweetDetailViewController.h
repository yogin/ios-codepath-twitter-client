//
//  IDZTweetDetailViewController.h
//  TwitterClient
//
//  Created by Anthony Powles on 28/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDZTweet.h"
#import "IDZNewTweetViewController.h"

@interface IDZTweetDetailViewController : UIViewController <IDZNewTweetViewControllerDelegate>

@property (weak, nonatomic) id <IDZNewTweetViewControllerDelegate> delegate;

@property (strong, nonatomic) IDZTweet *tweet;

@end
