//
//  ComposeVC.m
//  twitter
//
//  Created by Angus Huang on 2/4/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "ComposeVC.h"
#import "UIImageView+AFNetworking.h"
#import "Notification.h"

@interface ComposeVC ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@property (strong, nonatomic) UIBarButtonItem *charCountBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *tweetBarButtonItem;

@property (strong, nonatomic) Tweet *replyToTweet;
@end

@implementation ComposeVC

static const NSInteger MAX_CHARS = 140;

- (id)init
{
    self = [super initWithNibName:@"ComposeVC" bundle:nil];

    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initReplyToTweet:(Tweet *)tweet
{
    self = [super initWithNibName:@"ComposeVC" bundle:nil];
    
    if (self) {
        self.replyToTweet = tweet;
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
    
    User *currentUser = [User currentUser];
    
    self.nameLabel.text = currentUser.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];
    [self.profileImageView setImageWithURL:currentUser.profileImageUrl];
    
    [self initTextView];
    
    [self initBarButtonItems];
}

- (void)initTextView
{
    if (self.replyToTweet) {
        
        NSString *screenName1 = self.replyToTweet.screenName;
        NSString *screenName2 = self.replyToTweet.originalScreenName;
        
        if ([screenName1 isEqualToString:screenName2]) {
            self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", screenName1];
        } else {
            self.tweetTextView.text = [NSString stringWithFormat:@"@%@ @%@ ", screenName1, screenName2];
        }
    }
    
    // Set the TextView delegate to this class.
    self.tweetTextView.delegate = self;
}

- (void)initBarButtonItems
{
    // Add the character count bar button items (e.g. "140 Tweet").
    self.charCountBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"140"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    self.charCountBarButtonItem.enabled = NO;
    self.tweetBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(onTweetClicked)];
    self.tweetBarButtonItem.enabled = NO;
    
    NSArray *rightBarButtonItems = [NSArray arrayWithObjects:self.tweetBarButtonItem, self.charCountBarButtonItem, nil];
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems];
    
    // Add the cancel bar button item.
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(onCancelClicked)];
    [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//==============================================================================
#pragma mark - UITableViewDelegate
//==============================================================================

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger currentTextLength = textView.text.length;
    NSInteger deletedTextLength = range.length;
    NSInteger addedTextLength = text.length;
    
    NSInteger newTextLength = currentTextLength - deletedTextLength + addedTextLength;
    
    if (newTextLength > MAX_CHARS) {
        NSLog(@"New text exceeds maximum characters!");
        return NO;
    } else {
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger numEnteredChars = textView.text.length;
    NSInteger numRemainingChars = MAX_CHARS - numEnteredChars;
    
    // Update the remaining character count.
    self.charCountBarButtonItem.title = [NSString stringWithFormat:@"%d", numRemainingChars];
    
    // Only enable the "Tweet" button if there is some text entered.
    self.tweetBarButtonItem.enabled = (numRemainingChars > 0) ? YES : NO;
}

//==============================================================================
#pragma mark - Private Methods
//==============================================================================

- (void)onCancelClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTweetClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    void (^success)(AFHTTPRequestOperation *, id) = ^void(AFHTTPRequestOperation *operation, id response)
    {
        NSLog(@"onTweetClicked : success\n%@", response);
        
        Tweet *postedTweet = [[Tweet alloc] initWithDictionary:response];
        NSLog(@"postedTweet : %@", postedTweet.text);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NewTweetPosted
                                                            object:postedTweet];
    };
    
    void (^failure)(AFHTTPRequestOperation *, NSError *) = ^void(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"onTweetClicked : failure\n%@", error);
    };

    TwitterClient *twitterClient = [TwitterClient instance];
    [twitterClient tweet:self.tweetTextView.text success:success failure:failure];
}

@end
