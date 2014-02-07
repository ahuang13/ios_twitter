//
//  TweetDetailVC.m
//  twitter
//
//  Created by Angus Huang on 2/3/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "TweetDetailVC.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeVC.h"
#import "UINavigationController+Twitter.h"
#import "Notification.h"
#import "UIViewController+TweetController.h"

@interface TweetDetailVC ()

@property Tweet *tweet;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *numRetweetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFavoritesLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;

- (IBAction)onFavoriteClicked:(UIButton *)sender;
- (IBAction)onRetweetClicked:(UIButton *)sender;
- (IBAction)onReplyClicked:(UIButton *)sender;

@end

@implementation TweetDetailVC

static const int RETWEET_ALERT_TAG = 1;
static const int UNDO_RETWEET_ALERT_TAG = 2;

- (id)initWithTweet:(Tweet *)tweet
{
    self = [self initWithNibName:@"TweetDetailVC" bundle:nil];
    if (self) {
        self.tweet = tweet;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.navigationItem.title = @"Tweet";
    
    // Initialize "Reply" button.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onBarReplyClicked)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"Tweet = %@", self.tweet);
    
    self.nameLabel.text = self.tweet.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.screenName];
    self.tweetTextLabel.text = self.tweet.text;
    self.timestampLabel.text = self.tweet.createdAtString;
    [self.profileImageView setImageWithURL:self.tweet.profileImageUrl];
    
    self.numRetweetsLabel.text = [self.tweet.retweetCount stringValue];
    self.numFavoritesLabel.text = [self.tweet.favoriteCount stringValue];
    
    if (!self.tweet.isRetweet) {
        self.retweetLabelHeightConstraint.constant = 0;
        self.retweetLabelTopConstraint.constant = 0;
    } else {
        self.retweetLabelHeightConstraint.constant = 18;
        self.retweetLabelTopConstraint.constant = 4;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@ retweeted", self.tweet.originalName];
    }
    
    [self.favoriteButton setSelected:self.tweet.favorited];
    [self.retweetButton setSelected:self.tweet.retweeted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
            
        case RETWEET_ALERT_TAG:
            [self onRetweetAlertResponse:alertView clickedButtonAtIndex:buttonIndex];
            break;

        case UNDO_RETWEET_ALERT_TAG:
            [self onUndoRetweetAlertResponse:alertView clickedButtonAtIndex:buttonIndex];
            break;
            
        default:
            NSLog(@"Unrecognized UIAlertView w/ tag %d", alertView.tag);
            break;
    }
}

#pragma mark - IBAction Methods

- (IBAction)onFavoriteClicked:(UIButton *)sender
{
    // Set the favorited property on the Tweet.
    self.tweet.favorited = !self.tweet.favorited;
    
    // Toggle the selected state of the star button.
    [sender setSelected:self.tweet.favorited];
    
    // Post the favorite or unfavorite request.
    TwitterClient *twitterClient = [TwitterClient instance];
    if (self.tweet.favorited) {
        [twitterClient favoriteTweetWithId:self.tweet.tweetId success:nil failure:nil];
        [self favoriteCountAdd:1];
    } else {
        [twitterClient unfavoriteTweetWithId:self.tweet.tweetId success:nil failure:nil];
        [self favoriteCountAdd:-1];
    }
}

- (IBAction)onRetweetClicked:(UIButton *)sender
{
    if (self.tweet.retweeted) {
        [self showUndoRetweetAlert];
    } else {
        [self showRetweetAlert];
    }
}

- (IBAction)onReplyClicked:(UIButton *)sender
{
    [self onReplyToTweet:self.tweet];
}

#pragma mark - Private Methods

- (void)onBarReplyClicked
{
    [self onReplyToTweet:self.tweet];
}

- (void)favoriteCountAdd:(NSInteger)count
{
    NSInteger newFavoriteCount = [self.tweet.favoriteCount integerValue] + count;
    self.tweet.favoriteCount = [NSNumber numberWithInteger:newFavoriteCount];
    
    self.numFavoritesLabel.text = [self.tweet.favoriteCount stringValue];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoriteStatusUpdated
                                                        object:nil];
}

- (void)showRetweetAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Retweet"
                                                    message:@"Retweet this to your followers?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Retweet", nil];
    [alert setTag:RETWEET_ALERT_TAG];
    [alert show];
}

- (void)showUndoRetweetAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Retweet"
                                                    message:@"Undo this retweet?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Undo", nil];
    [alert setTag:UNDO_RETWEET_ALERT_TAG];
    [alert show];
}

- (void)onRetweetAlertResponse:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If "Retweet" was clicked...
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self retweetTweet:self.tweet];
    }
}

- (void)onUndoRetweetAlertResponse:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If "Undo" was clicked...
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self undoRetweet:self.tweet];
    }
}

@end
