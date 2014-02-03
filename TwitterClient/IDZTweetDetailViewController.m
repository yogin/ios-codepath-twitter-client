//
//  IDZTweetDetailViewController.m
//  TwitterClient
//
//  Created by Anthony Powles on 28/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import "IDZTweetDetailViewController.h"
#import <UIImageView+AFNetworking.h>

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
	
	self.favoriteCount.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
	self.retweetCount.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
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

@end
