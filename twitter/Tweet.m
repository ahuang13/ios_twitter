//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super initWithDictionary:data];
    if (self) {
        [self parse:data];
    }
    return self;
}

- (void)parse:(NSDictionary *)data
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    });

    _tweetId = [[self.data valueForKey:@"id"] longLongValue];
    
    _favorited = [[self.data valueForKey:@"favorited"] boolValue];
    
    _originalName = [self.data valueOrNilForKeyPath:@"user.name"];
    _originalScreenName = [self.data valueOrNilForKeyPath:@"user.screen_name"];

    NSString *profileImageUrlString;
    
    if ([self.data valueForKey:@"retweeted_status"]) {
        _name = [self.data valueOrNilForKeyPath:@"retweeted_status.user.name"];
        _screenName = [self.data valueOrNilForKeyPath:@"retweeted_status.user.screen_name"];
        profileImageUrlString = [self.data valueOrNilForKeyPath:@"retweeted_status.user.profile_image_url"];
    } else {
        _name = _originalName;
        _screenName = _originalScreenName;
        profileImageUrlString = [self.data valueOrNilForKeyPath:@"user.profile_image_url"];
    }
    _profileImageUrl = [NSURL URLWithString:profileImageUrlString];
    
    _text = [self.data valueOrNilForKeyPath:@"text"];
    
    NSString *createdAtString = [self.data valueForKey:@"created_at"];
    _createdAt = [dateFormatter dateFromString:createdAtString];
    
    NSDictionary *retweetStatusDict = [self.data valueForKey:@"retweeted_status"];
    _isRetweet = (retweetStatusDict != nil);
    
    _favoriteCount = [self.data valueForKey:@"favorite_count"];
    
    _retweetCount = [self.data valueForKey:@"retweet_count"];
}

- (NSAttributedString *)nameAndScreenName {
    
    NSString *unattributedString = [NSString stringWithFormat:@"%@ @%@", self.name, self.screenName];
    
    NSRange nameRange = NSMakeRange(0, self.name.length);
    NSRange screenNameRange = NSMakeRange(self.name.length + 1, self.screenName.length + 1);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:unattributedString];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:nameRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:11] range:screenNameRange];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:screenNameRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:screenNameRange];
    
    return attributedString;
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:params]];
    }
    return tweets;
}

@end
