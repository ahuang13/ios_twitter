//
//  Tweet.m
//  twitter
//
//  Created by Timothy Lee on 8/5/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

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

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:params]];
    }
    return tweets;
}

@end
