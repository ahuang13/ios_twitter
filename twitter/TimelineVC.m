//
//  TimelineVC.m
//  twitter
//
//  Created by Timothy Lee on 8/4/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TimelineVC.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+Timestamp.h"
#import "TweetDetailVC.h"
#import "ComposeVC.h"
#import "UINavigationController+Twitter.h"
#import "SVPullToRefresh.h"
#import "Notification.h"
#import "UIViewController+TweetController.h"

@interface TimelineVC ()

@property (nonatomic, strong) NSMutableArray *tweets;

@property BOOL isLoading;

- (void)onSignOutButton;
- (void)reload;

@end

@implementation TimelineVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Twitter";
        [self reload];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize navigation bar buttons.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNewClicked)];
    
    // Need to call this to make sure TableView separators go to the edge.
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    // Initialize pull-to-refresh.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    
    // Initialize infinite scrolling.
    __weak typeof(self) weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^void() {
        [weakSelf loadMore];
    }];
    
    // Display the loading indicator on start up.
    if (self.isLoading) {
        [self.refreshControl beginRefreshing];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNewPostTweetedNotification:)
                                                 name:NewTweetPosted
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTweetFavoritedNotification:)
                                                 name:FavoriteStatusUpdated
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRetweetedNotification:)
                                                 name:RetweetedStatusUpdated
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Hide separator lines when there are no tweets.
    NSInteger numberOfRows = self.tweets.count;
    if (numberOfRows == 0) {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    } else {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get a reference to the TweetCell.
    TweetCell *cell = [TimelineVC nextTweetCellForTableView:tableView];
    
    // Set the row index on the cell.
    [cell setTag:indexPath.row];
    
    // Set the button action handlers.
    [cell.replyButton setTag:indexPath.row];
    [cell.replyButton addTarget:self action:@selector(onReplyClicked:) forControlEvents:UIControlEventTouchUpInside];

    [cell.retweetButton setTag:indexPath.row];
    [cell.retweetButton addTarget:self action:@selector(onRetweetClicked:) forControlEvents:UIControlEventTouchUpInside];

    [cell.favoriteButton setTag:indexPath.row];
    [cell.favoriteButton addTarget:self action:@selector(onFavoriteClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // Get the current Tweet.
    Tweet *tweet = self.tweets[indexPath.row];
    
    // Initialize the cell contents with the Tweet.
    cell.nameLabel.attributedText = tweet.nameAndScreenName;
    cell.tweetLabel.text = tweet.text;
    cell.timestampLabel.text = [tweet.createdAt formattedTimeAgo];
    [cell.profileImageView setImageWithURL:tweet.profileImageUrl];
    if (!tweet.isRetweet) {
        cell.retweetedViewHeightConstraint.constant = 0;
        cell.retweetedViewTopConstraint.constant = 0;
    } else {
        cell.retweetedViewHeightConstraint.constant = 18;
        cell.retweetedViewTopConstraint.constant = 4;
        cell.retweetedLabel.text = [NSString stringWithFormat:@"%@ retweeted", tweet.originalName];
    }
    
    NSLog(@"text = %@", tweet.text);
    NSLog(@"retweetedId = %lld", tweet.currentUserRetweetedId);
    
    [cell.favoriteButton setSelected:tweet.favorited];
    [cell.retweetButton setSelected:tweet.retweeted];
    
    return cell;
}

// Gets the next cell for the TableView by taking the next reusable cell. If no
// reusable cell exists, then allocs a new cell and returns that.
+ (TweetCell *)nextTweetCellForTableView:(UITableView *)tableView {
    
    static NSString *CellIdentifier = @"TweetCell";
    
    TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TweetCell" owner:self options:nil];
        cell = (TweetCell *)[nib objectAtIndex:0];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.tweets[indexPath.row];
    NSString *text = tweet.text;
    
    CGFloat width = self.tableView.frame.size.width - 64;
    CGSize size = CGSizeMake(width, MAXFLOAT);
    
    UIFont *font = [UIFont systemFontOfSize:11];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    
    CGRect boundingRect = [text boundingRectWithSize:size
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
    
    NSInteger height = ceil(boundingRect.size.height);
    
    // Add height for retweet label.
    if (tweet.isRetweet) {
        height += 4 + 18;
    }
    
    // Add height for name labels.
    height += 8 + 14;
    
    // Add height for tweet top margin.
    height += -3;
    
    // Add height for bottom icons.
    height += 8 + 10 + 8;
    
    // Add other static adjustment.
    height += 12;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Make the "pressed" state temporary by immediately unselecting the row.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"didSelectRowAtIndexPath = %d", indexPath.row);
    
    Tweet *tweet = self.tweets[indexPath.row];
    TweetDetailVC *tweetDetailVC = [[TweetDetailVC alloc] initWithTweet:tweet];
    [[self navigationController] pushViewController:tweetDetailVC animated:YES];
}

#pragma mark - Private methods

- (void)onSignOutButton
{
    [User setCurrentUser:nil];
}

- (void)onNewClicked
{
    NSLog(@"onNewClicked");
    
    ComposeVC *composeVC = [[ComposeVC alloc] init];
    UINavigationController *composeNVC = [[UINavigationController alloc] initWithRootViewController:composeVC];
    [composeNVC setTwitterNavigationBarStyle];
    [[self navigationController] presentViewController:composeNVC animated:YES completion:nil];
}

- (void)onReplyClicked:(UIButton *)sender
{
    NSInteger index = sender.tag;
    Tweet *tweet = self.tweets[index];
    
    [self onReplyToTweet:tweet];
}

- (void)onRetweetClicked:(UIButton *)sender
{
    NSInteger index = sender.tag;
    Tweet *tweet = self.tweets[index];
    
    if (tweet.currentUserRetweetedId) {
        [self unretweet:tweet button:sender label:nil];
    } else {
        [self retweetTweet:tweet button:sender label:nil];
    }
}

- (void)onFavoriteClicked:(UIButton *)sender
{
    NSInteger index = sender.tag;
    Tweet *tweet = self.tweets[index];
    
    [self onFavoriteTweet:tweet button:sender label:nil];
}

- (void)onNewPostTweetedNotification:(NSNotification *) notification
{
    Tweet *tweet = notification.object;
    
    [self.tweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

- (void)onTweetFavoritedNotification:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)onRetweetedNotification:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)reload
{
    self.isLoading = YES;
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:nil maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
//        NSLog(@"%@", response);
        self.tweets = [Tweet tweetsWithArray:response];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        [self.tableView.infiniteScrollingView stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.refreshControl endRefreshing];
        [self.tableView.infiniteScrollingView stopAnimating];
    }];
}

- (void)loadMore
{
    TwitterClient *twitterClient = [TwitterClient instance];
    
    Tweet *currentOldestTweet = [self.tweets lastObject];
    long long currentOldestTweetId = currentOldestTweet.tweetId;
    NSLog(@"currentOldestTweetId = %lld", currentOldestTweetId);
    
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^void(AFHTTPRequestOperation *operation, id response)
    {
        // Add newly downloaded tweets to existing array of Tweets.
        NSMutableArray *newTweets = [Tweet tweetsWithArray:response];
        [self.tweets addObjectsFromArray:newTweets];
        
        // Reload the tableView.
        [self.tableView reloadData];
        
        // Reset infinite scroll view state.
        [self.tableView.infiniteScrollingView stopAnimating];
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^void(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"loadMore : failure");
        [self.tableView.infiniteScrollingView stopAnimating];
    };
    
    [twitterClient homeTimelineWithCount:20
                                 sinceId:0
                                   maxId:currentOldestTweetId - 1
                                 success:successBlock
                                 failure:failureBlock];
}

@end
