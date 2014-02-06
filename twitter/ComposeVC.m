//
//  ComposeVC.m
//  twitter
//
//  Created by Angus Huang on 2/4/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "ComposeVC.h"
#import "UIImageView+AFNetworking.h"

@interface ComposeVC ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property (strong, nonatomic) UIBarButtonItem *charCountBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *tweetBarButtonItem;

@end

@implementation ComposeVC

static const NSInteger MAX_CHARS = 140;

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
    
    // Set the TextView delegate to this class.
    self.tweetTextView.delegate = self;
    
    // Add the character count bar button items (e.g. "140 Tweet").
    self.charCountBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.charCountBarButtonItem.enabled = NO;
    self.tweetBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetClicked)];
    self.tweetBarButtonItem.enabled = NO;
    
    NSArray *rightBarButtonItems = [NSArray arrayWithObjects:self.tweetBarButtonItem, self.charCountBarButtonItem, nil];
    [self.navigationItem setRightBarButtonItems:rightBarButtonItems];
    
    // Add the cancel bar button item.
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelClicked)];
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
    // TODO
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
