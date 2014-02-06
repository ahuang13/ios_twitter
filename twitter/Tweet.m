//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (NSString *)tweetId {
    NSString *tweetIdNumber = [self.data valueOrNilForKeyPath:@"id_str"];
    NSLog(@"NSNumber = %@", tweetIdNumber);
    NSLog(@"NSNumber = %ld", NSIntegerMax);

    return tweetIdNumber;
}

- (NSString *)originalName {
    return [self.data valueOrNilForKeyPath:@"user.name"];
    
}

- (NSString *)name {
    
    NSString *name = [self.data valueOrNilForKeyPath:@"retweeted_status.user.name"];
    if (name == nil) {
        name = [self.data valueOrNilForKeyPath:@"user.name"];
    }
    
    return name;
}

- (NSString *)screenName {
    
    NSString *screenName = [self.data valueOrNilForKeyPath:@"retweeted_status.user.screen_name"];
    
    if (screenName == nil) {
        screenName = [self.data valueOrNilForKeyPath:@"user.screen_name"];
    }
    
    return screenName;
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

- (NSString *)text {
    return [self.data valueOrNilForKeyPath:@"text"];
}

- (NSURL *)profileImageUrl {
    
    NSString *profileImageUrlString = [self.data valueOrNilForKeyPath:@"retweeted_status.user.profile_image_url"];
    
    if (profileImageUrlString == nil) {
        profileImageUrlString = [self.data valueOrNilForKeyPath:@"user.profile_image_url"];
    }
    
    return [NSURL URLWithString:profileImageUrlString];
}

- (NSDate *)createdAt {
    
    // TODO: Avoid allocating this every time this method is called.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
    
    NSString *createdAtString = [self.data valueOrNilForKeyPath:@"created_at"];
    
    NSDate *createdAtDate = [formatter dateFromString:createdAtString];
    
    return createdAtDate;
}

- (BOOL)isRetweet {
    NSDictionary *retweetStatusDict = [self.data valueOrNilForKeyPath:@"retweeted_status"];
    return (retweetStatusDict != nil);
}

- (NSNumber *)favoriteCount {
    return [self.data valueForKey:@"favorite_count"];
}

- (NSNumber *)retweetCount {
    return [self.data valueForKey:@"retweet_count"];
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:params]];
    }
    return tweets;
}

@end
