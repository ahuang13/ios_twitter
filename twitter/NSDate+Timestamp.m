//
//  NSDate+Timestamp.m
//  twitter
//
//  Created by Angus Huang on 2/3/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "NSDate+Timestamp.h"

@implementation NSDate (Timestamp)

const int SECONDS_IN_MINUTE = 60;
const int SECONDS_IN_HOUR = SECONDS_IN_MINUTE * 60;
const int SECONDS_IN_DAY = SECONDS_IN_HOUR * 24;
const int SECONDS_IN_WEEK = SECONDS_IN_DAY * 7;

- (NSString *)formattedTimeAgo {
    
    NSInteger secondsAgo = -1 * [self timeIntervalSinceNow];
    
    NSString *formattedTimeAgo;
    if ( secondsAgo < SECONDS_IN_MINUTE ) {
        formattedTimeAgo = [NSString stringWithFormat:@"%ds", secondsAgo];
    } else if (secondsAgo < SECONDS_IN_HOUR) {
        NSInteger minutesAgo = secondsAgo / SECONDS_IN_MINUTE;
        formattedTimeAgo = [NSString stringWithFormat:@"%dm", minutesAgo];
    } else if (secondsAgo < SECONDS_IN_DAY) {
        NSInteger hoursAgo = secondsAgo / SECONDS_IN_HOUR;
        formattedTimeAgo = [NSString stringWithFormat:@"%dh", hoursAgo];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        formattedTimeAgo = [formatter stringFromDate:self];
    }

    return formattedTimeAgo;
}

@end
