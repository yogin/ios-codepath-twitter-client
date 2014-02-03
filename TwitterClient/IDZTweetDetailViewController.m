//
//  IDZTweetDetailViewController.m
//  TwitterClient
//
//  Created by Anthony Powles on 28/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import "IDZTweetDetailViewController.h"
#import <UIImageView+AFNetworking.h>
#import "IDZNewTweetViewController.h"

@interface IDZTweetDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *overheadView;
@property (weak, nonatomic) IBOutlet UILabel *overheadTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *overheadHeightConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *userTagName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UITextView *messageText;

@property (weak, nonatomic) IBOutlet UILabel *retweetCount;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCount;
@property (weak, nonatomic) IBOutlet UILabel *favoriteLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;

- (IBAction)onFavorite:(id)sender;
- (IBAction)onRetweet:(id)sender;

@end

@implementation IDZTweetDetailViewController

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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	NSLog(@"tweet details %@", self.tweet);
	
	self.userDisplayName.text = self.tweet.author.name;
	self.userTagName.text = [NSString stringWithFormat:@"@%@", self.tweet.author.screenName];
	self.timeLabel.text = self.tweet.displayCreatedAt;
	[self.userImage setImageWithURL:[NSURL URLWithString:self.tweet.author.profileUrl]];

    self.messageText.translatesAutoresizingMaskIntoConstraints = YES;
	self.messageText.text = self.tweet.text;
	[self.messageText sizeToFit];

	if (self.tweet.isRetweet) {
		self.overheadTitle.text = [NSString stringWithFormat:@"%@ retweeted", self.tweet.retweeter.name];
	}
	else {
		self.overheadTitle.text = nil;
		self.overheadHeightConstraint.constant = 0;
	}
	
	[self updateFavoriteCount];
	[self updateRetweetCount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isPortraitOrientation
{
	return [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait;
}

- (void)updateFavoriteCount
{
	self.favoriteCount.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
	self.favoriteLabel.textColor = self.tweet.isFavorite ? [UIColor orangeColor] : [UIColor lightGrayColor];
}

- (void)updateRetweetCount
{
	self.retweetCount.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
	self.retweetLabel.textColor = self.tweet.isRetweeted ? [UIColor orangeColor] : [UIColor lightGrayColor];
}

#pragma mark - Actions

- (IBAction)onFavorite:(id)sender
{
	if (self.tweet.isFavorite) {
		[self.tweet removeFromFavorites];
	}
	else {
		[self.tweet addToFavorites];
	}

	[self updateFavoriteCount];
}

- (IBAction)onRetweet:(id)sender
{
	if (self.tweet.isRetweeted) {
		[self.tweet unretweet];
	}
	else {
		[self.tweet retweet];
	}

	[self updateRetweetCount];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"ReplySegue"]) {
		IDZNewTweetViewController *replyViewController = [segue destinationViewController];
		[replyViewController prepareForReply:self.tweet];
	}
}

@end
