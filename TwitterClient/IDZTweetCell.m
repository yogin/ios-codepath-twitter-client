//
//  IDZTweetCell.m
//  TwitterClient
//
//  Created by Anthony Powles on 26/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import "IDZTweetCell.h"
#import <UIImageView+AFNetworking.h>

@interface IDZTweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userDisplayName;
@property (weak, nonatomic) IBOutlet UILabel *userTagName;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *overheadTitle;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *overheadHeightConstraint;

- (IBAction)onFavorite:(id)sender;
- (IBAction)onRetweet:(id)sender;

@property (strong, nonatomic) IDZTweet *tweet;

@end

@implementation IDZTweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateWithTweet:(IDZTweet *)tweet indexPath:(NSIndexPath *)indexPath
{
	self.tweet = tweet;
	self.tag = indexPath.row;
	self.replyButton.tag = self.tag;
	self.messageText.tag = self.tag;

	// there seems to be a bug in ios7 regarding uitextviews and link detection
	// setting the text to nil first seems to fix it
	self.messageText.text = nil;
	self.messageText.text = tweet.text;
	
	self.userDisplayName.text = tweet.author.name;
	self.userTagName.text = [NSString stringWithFormat:@"@%@", tweet.author.screenName];
	self.timeAgoLabel.text = tweet.elapsedCreatedAt;
	[self.userImage setImageWithURL:[NSURL URLWithString:tweet.author.profileUrl]];
	
	if (tweet.retweeter) {
		self.overheadHeightConstraint.constant = 30;
		self.overheadTitle.text = [NSString stringWithFormat:@"%@ retweeted", tweet.retweeter.name];
	}
	else {
		self.overheadHeightConstraint.constant = 0;
	}
}

- (IBAction)onFavorite:(id)sender
{
	if (self.tweet.isFavorite) {
		[self.tweet removeFromFavorites];
	}
	else {
		[self.tweet addToFavorites];
	}
}

- (IBAction)onRetweet:(id)sender
{
	if (self.tweet.isRetweeted) {
		[self.tweet unretweet];
	}
	else {
		[self.tweet retweet];
	}
}

@end
