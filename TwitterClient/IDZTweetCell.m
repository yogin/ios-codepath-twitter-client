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
@property (weak, nonatomic) IBOutlet UITextView *messageText;
@property (weak, nonatomic) IBOutlet UILabel *overheadTitle;
@property (weak, nonatomic) IBOutlet UIView *overheadView;

- (IBAction)onFavorite:(id)sender;
- (IBAction)onRetweet:(id)sender;
- (IBAction)onReply:(id)sender;

@property (strong, nonatomic) IDZTweet *tweet;

@end

@implementation IDZTweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithTweet:(IDZTweet *)tweet indexPath:(NSIndexPath *)indexPath
{
	self.tweet = tweet;
	self.tag = indexPath.row;

	self.overheadView.translatesAutoresizingMaskIntoConstraints = YES;

	// there seems to be a bug in ios7 regarding uitextviews and link detection
	// setting the text to nil first seems to fix it
	self.messageText.text = nil;
	self.messageText.text = tweet.text;
	
	self.userDisplayName.text = tweet.author.name;
	self.userTagName.text = [NSString stringWithFormat:@"@%@", tweet.author.screenName];
	self.timeAgoLabel.text = tweet.elapsedCreatedAt;
	[self.userImage setImageWithURL:[NSURL URLWithString:tweet.author.profileUrl]];
	
	CGFloat overheadHeight = 0;
	
	if (tweet.retweeter) {
		overheadHeight = 30;
		self.overheadTitle.text = [NSString stringWithFormat:@"%@ retweeted", tweet.retweeter.name];
	}
	
	CGRect viewFrame = self.overheadView.frame;
	viewFrame.size.height = overheadHeight;
	self.overheadView.frame = viewFrame;
}

- (IBAction)onReply:(id)sender
{
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
