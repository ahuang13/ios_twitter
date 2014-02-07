//
//  TwitterClient.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "AFOAuth1Client.h"

@interface TwitterClient : AFOAuth1Client

+ (TwitterClient *)instance;

// Users API

- (void)authorizeWithCallbackUrl:(NSURL *)callbackUrl
                         success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success
                         failure:(void (^)(NSError *error))failure;

- (void)currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success
                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Statuses API

- (void)homeTimelineWithCount:(int)count
                      sinceId:(NSString *)sinceId
                        maxId:(long long)maxId
                      success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Favorites API

- (void)favoriteTweetWithId:(long long)tweetId
                    success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)unfavoriteTweetWithId:(long long)tweetId
                      success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Post Tweet API

- (void)tweet:(NSString *)text
      success:(void (^)(AFHTTPRequestOperation *operation, id response))success
      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)tweet:(NSString *)text
  inReplyToId:(long long)replyToId
      success:(void (^)(AFHTTPRequestOperation *operation, id response))success
      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Retweets API

- (void)retweetWithId:(long long)tweetId
              success:(void (^)(AFHTTPRequestOperation *operation, id response))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)unretweetWithId:(long long)retweetId
                success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
