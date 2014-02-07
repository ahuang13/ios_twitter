//
//  UIViewController+TweetController.m
//  twitter
//
//  Created by Angus Huang on 2/7/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "UIViewController+TweetController.h"
#import "ComposeVC.h"
#import "UINavigationController+Twitter.h"
#import "Notification.h"

@implementation UIViewController (TweetController)

- (void)onReplyToTweet:(Tweet *)originalTweet
{
    ComposeVC *composeVC = [[ComposeVC alloc] initReplyToTweet:originalTweet];

    UINavigationController *composeNVC = [[UINavigationController alloc] initWithRootViewController:composeVC];
    [composeNVC setTwitterNavigationBarStyle];

    [[self navigationController] presentViewController:composeNVC animated:YES completion:nil];
}

- (void)onFavoriteTweet:(Tweet *)tweet button:(UIButton *)favoriteButton label:(UILabel *)favoriteCountLabel
{
    // Set the favorited property on the Tweet.
    tweet.favorited = !tweet.favorited;
    
    // Toggle the selected state of the star button.
    [favoriteButton setSelected:tweet.favorited];
    
    // Post the favorite or unfavorite request.
    TwitterClient *twitterClient = [TwitterClient instance];
    if (tweet.favorited) {
        [twitterClient favoriteTweetWithId:tweet.tweetId success:nil failure:nil];
        [self favoriteCountAdd:1 toLabel:favoriteCountLabel forTweet:tweet];
    } else {
        [twitterClient unfavoriteTweetWithId:tweet.tweetId success:nil failure:nil];
        [self favoriteCountAdd:-1 toLabel:favoriteCountLabel forTweet:tweet];
    }
    
    // Notify the timeline to reload its data.
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoriteStatusUpdated
                                                        object:nil];
}

- (void)retweetTweet:(Tweet *)originalTweet button:(UIButton *)retweetButton label:(UILabel *)retweetCountLabel
{
    // Update retweeted stats in the Tweet object.
    originalTweet.retweeted = YES;
    NSInteger newRetweetCount = [originalTweet.retweetCount integerValue] + 1;
    originalTweet.retweetCount = [NSNumber numberWithInteger:newRetweetCount];

    // Update the label.
    retweetCountLabel.text = [originalTweet.retweetCount stringValue];
    
    // Toggle the selected state of the retweet button.
    [retweetButton setSelected:originalTweet.retweeted];

    TwitterClient *twitterClient = [TwitterClient instance];
    long long tweetId = originalTweet.tweetId;
    
    // Post the retweet.
    [twitterClient retweetWithId:tweetId success:nil failure:nil];

    // Notify the timeline to reload its data.
    [[NSNotificationCenter defaultCenter] postNotificationName:RetweetedStatusUpdated
                                                        object:nil];
}

- (void)unretweet:(Tweet *)originalTweet button:(UIButton *)retweetButton label:(UILabel *)retweetCountLabel
{
    // Update retweeted stats in the Tweet object.
    originalTweet.retweeted = NO;
    NSInteger newRetweetCount = [originalTweet.retweetCount integerValue] - 1;
    originalTweet.retweetCount = [NSNumber numberWithInteger:newRetweetCount];

    // Update the label.
    retweetCountLabel.text = [originalTweet.retweetCount stringValue];

    // Toggle the selected state of the retweet button.
    [retweetButton setSelected:originalTweet.retweeted];

    TwitterClient *twitterClient = [TwitterClient instance];
    long long retweetedId = originalTweet.currentUserRetweetedId;
    
    NSLog(@"unretweet : %lld", retweetedId);
    
    // Post the retweet.
    [twitterClient destroyTweetWithId:retweetedId success:nil failure:nil];
    
    // Notify the timeline to reload its data.
    [[NSNotificationCenter defaultCenter] postNotificationName:RetweetedStatusUpdated
                                                        object:nil];
}

#pragma mark - Private Methods

- (void)favoriteCountAdd:(NSInteger)count toLabel:(UILabel *)label forTweet:(Tweet *)tweet
{
    NSInteger newFavoriteCount = [tweet.favoriteCount integerValue] + count;
    tweet.favoriteCount = [NSNumber numberWithInteger:newFavoriteCount];
    
    label.text = [tweet.favoriteCount stringValue];
}

@end
