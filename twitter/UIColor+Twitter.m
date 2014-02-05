//
//  UIColor+Twitter.m
//  twitter
//
//  Created by Angus Huang on 2/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "UIColor+Twitter.h"

@implementation UIColor (Twitter)

+ (UIColor *)twitterBlueColor
{
    static UIColor *twitterBlue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        twitterBlue = [[UIColor alloc] initWithRed:0.25 green:0.6 blue:1.0 alpha:0.5];
    });

    return twitterBlue;
}

@end
