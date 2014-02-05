//
//  UINavigationController+Twitter.m
//  twitter
//
//  Created by Angus Huang on 2/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "UINavigationController+Twitter.h"
#import "UIColor+Twitter.h"


@implementation UINavigationController (Twitter)

- (void)setTwitterNavigationBarStyle
{
    self.navigationBar.barTintColor = [UIColor twitterBlueColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationBar.translucent = NO;
    self.navigationBar.opaque = YES;
}

@end
