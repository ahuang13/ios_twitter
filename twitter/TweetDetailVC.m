//
//  TweetDetailVC.m
//  twitter
//
//  Created by Angus Huang on 2/3/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "TweetDetailVC.h"

@interface TweetDetailVC ()

@property Tweet *tweet;

@end

@implementation TweetDetailVC

- (id)initWithTweet:(Tweet *)tweet
{
    self = [self initWithNibName:@"TweetDetailVC" bundle:nil];
    if (self) {
        self.tweet = tweet;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"Tweet = %@", self.tweet);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
