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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"Tweet = %@", self.tweet);
    
    self.nameLabel.text = self.tweet.name;
    self.screenNameLabel.text = self.tweet.screenName;
    self.tweetTextLabel.text = self.tweet.text;
    self.timestampLabel.text = nil;//self.tweet.createdAt;
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
