//
//  IDZNewTweetViewController.m
//  TwitterClient
//
//  Created by Anthony Powles on 31/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import "IDZNewTweetViewController.h"
#import <UIImageView+AFNetworking.h>

@interface IDZNewTweetViewController ()

@property (strong, nonatomic) UIBarButtonItem *characterCount;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *userTagName;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;

- (IBAction)onTweetButton:(id)sender;
- (IBAction)onCancelButton:(id)sender;

@property (strong, nonatomic) IDZTweet *tweet;

@end

@implementation IDZNewTweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tweetText.delegate = self;

	// add a fake button to act as the character count
	self.characterCount = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:nil action:nil];
//	self.characterCount.enabled = NO;
	self.navigationItem.rightBarButtonItems = @[self.tweetButton, self.characterCount];

	// start with tweet button disabled to prevent posting empty tweets
	self.tweetButton.enabled = NO;
	
	IDZUser *currentUser = [IDZUser currentUser];
	self.userDisplayName.text = currentUser.name;
	self.userTagName.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];
	[self.userImage setImageWithURL:[NSURL URLWithString:currentUser.profileUrl]];
	
	self.tweetText.text = self.tweet ? [NSString stringWithFormat:@"@%@ ", self.tweet.author.screenName] : @"";
	[self.tweetText becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self updateNavigationButtonsWithCount];
}

- (void)updateNavigationButtonsWithCount
{
	int count = 140 - (int)self.tweetText.text.length;

	if (count >= 0 && count < 140) {
		self.tweetButton.enabled = YES;
		self.characterCount.title = [NSString stringWithFormat:@"%d", count];
		self.characterCount.tintColor = [UIColor lightGrayColor];
	}
	else {
		self.tweetButton.enabled = NO;
		self.characterCount.title = [NSString stringWithFormat:@"%d", count > 0 ? count : -count];
		self.characterCount.tintColor = [UIColor redColor];
	}
}

- (void)prepareForReply:(IDZTweet *)tweet
{
	self.tweet = tweet;
}

#pragma mark - UITextView Delegate

- (void)textViewDidChange:(UITextView *)textView
{
//	int count = 140 - (int)textView.text.length;
	[self updateNavigationButtonsWithCount];
}

#pragma mark - Actions

- (IBAction)onTweetButton:(id)sender
{
	IDZTweet *newTweet = [IDZTweet updateStatus:self.tweetText.text withSuccess:nil andFailure:nil];
	[self.delegate addNewTweet:newTweet];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCancelButton:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

@end
