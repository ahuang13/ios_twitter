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
    
    // Post the favorite or unfavorite request.
    TwitterClient *twitterClient = [TwitterClient instance];
    if (tweet.favorited) {
        [twitterClient favoriteTweetWithId:tweet.tweetId success:nil failure:nil];
        [self favoriteCountAdd:1 toLabel:favoriteCountLabel forTweet:tweet];
    } else {
        [twitterClient unfavoriteTweetWithId:tweet.tweetId success:nil failure:nil];
        [self favoriteCountAdd:-1 toLabel:favoriteCountLabel forTweet:tweet];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoriteStatusUpdated
                                                        object:nil];
}

- (void)retweetTweet:(Tweet *)originalTweet
{
    TwitterClient *twitterClient = [TwitterClient instance];
    long long tweetId = originalTweet.tweetId;
    
    void (^success)(AFHTTPRequestOperation *, id) = ^void(AFHTTPRequestOperation *operation, id response)
    {
        Tweet *postedTweet = [[Tweet alloc] initWithDictionary:response];
        [[NSNotificationCenter defaultCenter] postNotificationName:NewTweetPosted
                                                            object:postedTweet];
    };
    
    [twitterClient retweetWithId:tweetId success:success failure:nil];
    
    originalTweet.retweeted = YES;
    NSInteger newRetweetCount = [originalTweet.retweetCount integerValue] + 1;
    originalTweet.retweetCount = [NSNumber numberWithInteger:newRetweetCount];
}

- (void)undoRetweet:(Tweet *)originalTweet
{
    // TODO
    TwitterClient *twitterClient = [TwitterClient instance];
    //long long retweetId = self.tweet.retweetId;
    //[twitterClient unretweetWithId:retweetId success:nil failure:nil];
    
    originalTweet.retweeted = NO;
    NSInteger newRetweetCount = [originalTweet.retweetCount integerValue] - 1;
    originalTweet.retweetCount = [NSNumber numberWithInteger:newRetweetCount];
}

#pragma mark - Private Methods

- (void)favoriteCountAdd:(NSInteger)count toLabel:(UILabel *)label forTweet:(Tweet *)tweet
{
    NSInteger newFavoriteCount = [tweet.favoriteCount integerValue] + count;
    tweet.favoriteCount = [NSNumber numberWithInteger:newFavoriteCount];
    
    label.text = [tweet.favoriteCount stringValue];
}

@end
