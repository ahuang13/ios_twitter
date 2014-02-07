//
//  TwitterClient.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "TwitterClient.h"
#import "AFNetworking.h"

#define TWITTER_BASE_URL [NSURL URLWithString:@"https://api.twitter.com/"]
#define TWITTER_CONSUMER_KEY @"biYAqubJD0rK2cRatIQTZw"
#define TWITTER_CONSUMER_SECRET @"2cygl2irBgMQVNuWJwMn6vXiyDnWtht7gSyuRnf0Fg"

static NSString * const kAccessTokenKey = @"kAccessTokenKey";

@implementation TwitterClient

+ (TwitterClient *)instance {
    static dispatch_once_t once;
    static TwitterClient *instance;
    
    dispatch_once(&once, ^{
        instance = [[TwitterClient alloc] initWithBaseURL:TWITTER_BASE_URL key:TWITTER_CONSUMER_KEY secret:TWITTER_CONSUMER_SECRET];
    });
    
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
    self = [super initWithBaseURL:TWITTER_BASE_URL key:TWITTER_CONSUMER_KEY secret:TWITTER_CONSUMER_SECRET];
    if (self != nil) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:kAccessTokenKey];
        if (data) {
            self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return self;
}

#pragma mark - Users API

- (void)authorizeWithCallbackUrl:(NSURL *)callbackUrl success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success failure:(void (^)(NSError *error))failure {
    self.accessToken = nil;
    [super authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token" userAuthorizationPath:@"oauth/authorize" callbackURL:callbackUrl accessTokenPath:@"oauth/access_token" accessMethod:@"POST" scope:nil success:success failure:failure];
}

- (void)currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [self getPath:@"1.1/account/verify_credentials.json" parameters:nil success:success failure:failure];
}

#pragma mark - Statuses API

- (void)homeTimelineWithCount:(int)count sinceId:(NSString *)sinceId maxId:(long long)maxId success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"count": @(count)}];
    if (sinceId) {
        [params setObject:sinceId forKey:@"since_id"];
    }
    if (maxId > 0) {
        [params setObject:@(maxId) forKey:@"max_id"];
    }
    [self getPath:@"1.1/statuses/home_timeline.json" parameters:params success:success failure:failure];
}

#pragma mark - Favorites API

- (void)favoriteTweetWithId:(long long)tweetId
                    success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    static NSString *path = @"1.1/favorites/create.json";
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:@(tweetId) forKey:@"id"];
    
    [self postPath:path parameters:params success:success failure:failure];
}

- (void)unfavoriteTweetWithId:(long long)tweetId
                      success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    static NSString *path = @"1.1/favorites/destroy.json";
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:@(tweetId) forKey:@"id"];
    
    [self postPath:path parameters:params success:success failure:failure];
}

#pragma mark - Post Status API

- (void)tweet:(NSString *)text
      success:(void (^)(AFHTTPRequestOperation *operation, id response))success
      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self tweet:text inReplyToId:0 success:success failure:failure];
}

- (void)tweet:(NSString *)text
  inReplyToId:(long long)replyToId
      success:(void (^)(AFHTTPRequestOperation *operation, id response))success
      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    static NSString *path = @"1.1/statuses/update.json";
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:text forKey:@"status"];
    
    if (replyToId > 0) {
        [params setObject:@(replyToId) forKey:@"in_reply_to_status_id"];
    }
    
    [self postPath:path parameters:params success:success failure:failure];
}

#pragma mark - Retweet API

- (void)retweetWithId:(long long)tweetId
              success:(void (^)(AFHTTPRequestOperation *operation, id response))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"1.1/statuses/retweet/%lld.json", tweetId];
    
    [self postPath:path parameters:nil success:success failure:failure];
}

- (void)unretweetWithId:(long long)retweetId
                success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"1.1/statuses/destroy/%lld.json", retweetId];
    
    [self postPath:path parameters:nil success:success failure:failure];
}

#pragma mark - Private methods

- (void)setAccessToken:(AFOAuth1Token *)accessToken {
    [super setAccessToken:accessToken];
    
    if (accessToken) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAccessTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccessTokenKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
