//
//  IDZTweetsViewController.m
//  TwitterClient
//
//  Created by Anthony Powles on 25/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

//#import <UIImageView+AFNetworking.h>

#import "IDZTweetsViewController.h"
#import "IDZTwitterClient.h"
#import "IDZUser.h"
#import "IDZTweet.h"
#import "IDZTweetCell.h"

@interface IDZTweetsViewController ()

@property (strong, nonatomic) NSMutableArray *tweets;
@property (strong, nonatomic) NSTimer *nextTweetsTimer;

- (IBAction)onLogoutButton:(id)sender;

@end

@implementation IDZTweetsViewController

#pragma mark - Init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setup
{
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self
							action:@selector(onRefresh:forState:)
				  forControlEvents:UIControlEventValueChanged];

	[self loadTweets];
}

- (void)onRefresh:(id)sender forState:(UIControlState)state
{
	self.tweets = nil;
    [self loadTweets];
}

- (BOOL)isPortraitOrientation
{
	return [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait;
}

#pragma mark - Tweets

- (void)loadTweets
{
	if (!self.tweets) {
		NSLog(@"loading tweets!");
		self.tweets = [[NSMutableArray alloc] init];
		
		[IDZTweet fetchLast:50
				withSuccess:^(NSURLSessionDataTask *task, id responseObject) {
					[self appendTweets:responseObject];
					[self.tableView reloadData];
					[self.refreshControl endRefreshing];
				}
				 andFailure:^(NSURLSessionDataTask *task, NSError *error) {
					 NSLog(@"loadTweets failure %@", error);
				 }];
	}
	else {
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
	}
}

- (void)loadNextTweets:(NSTimer *)timer
{
	IDZTweet *lastTweet = self.tweets[self.tweets.count - 1];
	
	if (lastTweet) {
		[IDZTweet fetchNext:50
					  until:lastTweet.tweetId
				withSuccess:^(NSURLSessionDataTask *task, id responseObject) {
					[self appendTweets:responseObject];
					[self.tableView reloadData];
				}
				 andFailure:^(NSURLSessionDataTask *task, NSError *error) {
					 NSLog(@"loadNextTweets failure %@", error);
				 }];
	}
	else {
		[self loadTweets];
	}
}

- (void)appendTweets:(id)rawTweets
{
	for (NSDictionary *data in rawTweets) {
		[self.tweets addObject:[IDZTweet tweetFromJSON:data]];
	}
}

- (void)prependTweet:(IDZTweet *)tweet
{
	[self.tweets insertObject:tweet atIndex:0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tweetCell";
    IDZTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	IDZTweet *tweet = self.tweets[indexPath.row];
	[cell updateWithTweet:tweet indexPath:indexPath];

	// add a tap gesture on the UITextView so we can click on it to access the detail view
	// this is the only way I found to support the UITextView in readonly mode, and also detect links, and allow tapping
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTextViewTap:)];
	[gestureRecognizer setNumberOfTapsRequired:1];
	[cell.messageText addGestureRecognizer:gestureRecognizer];

    if (indexPath.row > (self.tweets.count - 10) && ![self.nextTweetsTimer isValid]) {
		// if we are close to the end of the list, we need to start loading more tweets
		self.nextTweetsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadNextTweets:) userInfo:nil repeats:NO];
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	IDZTweet *tweet = self.tweets[indexPath.row];
	UITextView *textView = [[UITextView alloc] init];
	
	CGFloat textViewHeight = [self heightForTextView:textView withItem:tweet];
	// TODO calculate heights of other elements
	CGFloat overheadHeight = tweet.isRetweet ? 20 : 0;

	return textViewHeight + overheadHeight;
}

- (CGFloat)heightForTextView:(UITextView *)textView withItem:(IDZTweet *)item
{
	if (item) {
		[textView setAttributedText:[[NSAttributedString alloc] initWithString:item.text]];
	}
	
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	CGFloat width = [self isPortraitOrientation] ? screenRect.size.width : screenRect.size.height;
	width -= 64;//84;
	
	textView.dataDetectorTypes = UIDataDetectorTypeLink;
	CGRect textRect = [textView.text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
												  options:NSStringDrawingUsesLineFragmentOrigin
											   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
												  context:nil];
	
	return textRect.size.height + 90;// + 105; // 70
}

- (void)onTextViewTap:(UITapGestureRecognizer *)sender
{
	if (sender.state == UIGestureRecognizerStateEnded) {
		[self performSegueWithIdentifier:@"DetailTweetSegue" sender:sender.view];
	}
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"NewTweetSegue"]) {
		IDZNewTweetViewController *newTweetController = [segue destinationViewController];
		newTweetController.delegate = self;
	}
	else if ([[segue identifier] isEqualToString:@"DetailTweetSegue"]) {
		IDZTweetDetailViewController *detailTweetController = [segue destinationViewController];
		// this segue can be triggered either from a IDZTweetCell or a UITextView
		// luckily both have their tags set, so it should be transparent :)
		int index = [((UIView *)sender) tag];
		[detailTweetController setTweet:self.tweets[index]];
	}
	else if ([[segue identifier] isEqualToString:@"ReplySegue"]) {
		IDZNewTweetViewController *replyViewController = [segue destinationViewController];
		int index = (int)[((IDZTweetCell*)sender) tag];
		replyViewController.delegate = self;
		[replyViewController prepareForReply:self.tweets[index]];
	}
}

#pragma mark - IBActions

- (IBAction)onLogoutButton:(id)sender
{
	[IDZUser logout];
}

#pragma mark - IDZNewTweetViewControllerDelegate

- (void)addNewTweet:(IDZTweet *)tweet
{
	NSLog(@"adding new tweet to the list");
	[self prependTweet:tweet];
}

@end
