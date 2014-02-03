//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

const int SECONDS_IN_MINUTE = 60;
const int SECONDS_IN_HOUR = SECONDS_IN_MINUTE * 60;
const int SECONDS_IN_DAY = SECONDS_IN_HOUR * 24;
const int SECONDS_IN_WEEK = SECONDS_IN_DAY * 7;

- (NSString *)name {
    return [self.data valueOrNilForKeyPath:@"user.name"];
}

- (NSString *)text {
    return [self.data valueOrNilForKeyPath:@"text"];
}

- (NSURL *)profileImageUrl {
    NSString *profileImageUrlString = [self.data valueOrNilForKeyPath:@"user.profile_image_url"];
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

- (NSString *)timestamp {
    
    NSDate *createdAtDate = self.createdAt;
    int secondsAgo = -1 * [createdAtDate timeIntervalSinceNow];
    
    NSString *timestamp;
    if ( secondsAgo < SECONDS_IN_MINUTE ) {
        timestamp = [NSString stringWithFormat:@"%ds", secondsAgo];
    } else if (secondsAgo < SECONDS_IN_HOUR) {
        int minutesAgo = secondsAgo / SECONDS_IN_MINUTE;
        timestamp = [NSString stringWithFormat:@"%dm", minutesAgo];
    } else if (secondsAgo < SECONDS_IN_DAY) {
        int hoursAgo = secondsAgo / SECONDS_IN_HOUR;
        timestamp = [NSString stringWithFormat:@"%dh", hoursAgo];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        timestamp = [formatter stringFromDate:createdAtDate];
    }
    
    return timestamp;
}

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:params]];
    }
    return tweets;
}

@end
