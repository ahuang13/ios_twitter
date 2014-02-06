//
//  Tweet.h
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : RestObject

@property (nonatomic, readonly) long long tweetId;
@property (nonatomic, strong, readonly) NSString *originalName;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *screenName;
@property (nonatomic, strong, readonly) NSAttributedString *nameAndScreenName;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSURL *profileImageUrl;
@property (nonatomic, strong, readonly) NSDate *createdAt;
@property (nonatomic, readonly) BOOL isRetweet;

@property (nonatomic, strong, readonly) NSNumber *favoriteCount;
@property (nonatomic, strong, readonly) NSNumber *retweetCount;

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array;

@end
