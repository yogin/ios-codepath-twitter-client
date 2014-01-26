//
//  IDZTweetsViewController.m
//  TwitterClient
//
//  Created by Anthony Powles on 25/01/14.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

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
    [self loadTweets];
}

#pragma mark - Tweets

- (void)loadTweets
{
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
	cell.messageText.text = tweet.text;
	cell.userDisplayName.text = tweet.author.name;
	cell.userTagName.text = tweet.author.screenName;

    if (indexPath.row > (self.tweets.count - 10) && ![self.nextTweetsTimer isValid]) {
		// if we are close to the end of the list, we need to start loading more tweets
		self.nextTweetsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadNextTweets:) userInfo:nil repeats:NO];
	}
	
    return cell;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - IBActions

- (IBAction)onLogoutButton:(id)sender
{
	[IDZUser logout];
}

@end