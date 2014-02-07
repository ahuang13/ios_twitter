//
//  UIViewController+TweetController.m
//  twitter
//
//  Created by Angus Huang on 2/7/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "UIViewController+TweetController.h"
#import "ComposeVC.h"
#import "UINavigationController+Twitter.h"

@implementation UIViewController (TweetController)

- (void)onReplyToTweet:(Tweet *)originalTweet
{
    ComposeVC *composeVC = [[ComposeVC alloc] initReplyToTweet:originalTweet];

    UINavigationController *composeNVC = [[UINavigationController alloc] initWithRootViewController:composeVC];
    [composeNVC setTwitterNavigationBarStyle];

    [[self navigationController] presentViewController:composeNVC animated:YES completion:nil];
}

@end
