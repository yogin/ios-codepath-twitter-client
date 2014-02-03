//
//  IDZTweetCell.h
//  TwitterClient
//
//  Created by Anthony Powles on 26/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDZTweet.h"

@interface IDZTweetCell : UITableViewCell

- (void)updateWithTweet:(IDZTweet *)tweet indexPath:(NSIndexPath *)indexPath;

@end
