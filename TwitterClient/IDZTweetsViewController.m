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
	[self loadTweets];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tweets

- (void)loadTweets
{
	[IDZTweet fetchLast:22
			withSuccess:^(NSURLSessionDataTask *task, id responseObject) {
//				NSLog(@"fetch success %@", responseObject);
				self.tweets = [[NSMutableArray alloc] init];
				
				for (NSDictionary *data in responseObject) {
					[self.tweets addObject:[IDZTweet tweetFromJSON:data]];
				}
				
				[self.tableView reloadData];
			}
			 andFailure:^(NSURLSessionDataTask *task, NSError *error) {
				 NSLog(@"fetch failure %@", error);
			 }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
