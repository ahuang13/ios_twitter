//
//  TweetDetailVC.m
//  twitter
//
//  Created by Angus Huang on 2/3/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "TweetDetailVC.h"
#import "UIImageView+AFNetworking.h"

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;

- (IBAction)onFavoriteClicked:(UIButton *)sender;
- (IBAction)onRetweetClicked:(UIButton *)sender;

@end

@implementation TweetDetailVC

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
                                                                             action:@selector(onReplyClicked)];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onReplyClicked
{
    NSLog(@"onReplyClicked");
    
    
}

- (void)favoriteCountAdd:(NSInteger)count
{
    NSInteger newFavoriteCount = [self.tweet.favoriteCount integerValue] + count;
    self.tweet.favoriteCount = [NSNumber numberWithInteger:newFavoriteCount];
    
    self.numFavoritesLabel.text = [self.tweet.favoriteCount stringValue];
}

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
    
}

@end
