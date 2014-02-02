//
//  IDZNewTweetViewController.h
//  TwitterClient
//
//  Created by Anthony Powles on 31/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDZUser.h"
#import "IDZTweet.h"

@protocol IDZNewTweetViewControllerDelegate <NSObject>

- (void)addNewTweet:(IDZTweet *)tweet;

@end

@interface IDZNewTweetViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) id <IDZNewTweetViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *userTagName;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;

- (IBAction)onTweetButton:(id)sender;
- (IBAction)onCancelButton:(id)sender;

@end