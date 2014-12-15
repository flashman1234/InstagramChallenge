//
//  ImageViewController.m
//  nxtbgthngrm
//
//  Created by Michal Thompson on 14/12/14.
//  Copyright (c) 2014 Michal Thompson. All rights reserved.
//

#import "ImageViewController.h"
#import "InstagramMedia.h"
#import "UIImageView+AFNetworking.h"
#import "InstagramComment.h"
#import "InstagramUser.h"
#import "UIAlertView+Blocks.h"

#define MAIL_BUTTON_ID 100

@interface ImageViewController ()
@property(weak, nonatomic) IBOutlet UIImageView *imageView;
@property(weak, nonatomic) IBOutlet UILabel *captionLabel;
@property(nonatomic) InstagramMedia *selectedMedia;

@end

@implementation ImageViewController {
    AAShareBubbles *shareBubbles;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showMedia];
}

// If the device is rotated, then reload the sharebubbles with CGPoint center.
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [shareBubbles hide];

    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
    }                            completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        if (shareBubbles) {
            [self setupShareBubble];
        }
    }];
}

- (void)showMedia {
    // get media and load image and labels.
    InstagramMedia *media = self.mediaArray[(NSUInteger) self.selectedIndex];
    self.selectedMedia = media;
    [self.imageView setImageWithURL:media.standardResolutionImageURL];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.title = media.user.username;

    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy"];

    NSString *dateString = [format stringFromDate:media.caption.createdDate];

    if (media.caption.createdDate != nil && media.caption.text.length > 0) {
        self.captionLabel.text = [NSString stringWithFormat:@"%@; %@", dateString, media.caption.text];
        [self.captionLabel layoutIfNeeded];
    }
}

#pragma mark - IBActions

- (IBAction)shareButtonPressed:(id)sender {
    [self setupShareBubble];
}

- (IBAction)instagramButtonPressed:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"instagram://media?id=%@", self.selectedMedia.Id];

    NSURL *instagramURL = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
    else {
        [self showSharePopup:@"Instagram"];
    }
}

- (IBAction)browserButtonPressed:(id)sender {
    NSString *urlString = self.selectedMedia.link;
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma mark AAShareBubbles setup and delegate

- (void)setupShareBubble {
    if (shareBubbles) {
        [shareBubbles hide];
        shareBubbles = nil;
    }
    shareBubbles = [[AAShareBubbles alloc] initWithPoint:self.view.center radius:150 inView:self.view];
    shareBubbles.delegate = self;
    shareBubbles.bubbleRadius = 40;
    shareBubbles.showFacebookBubble = YES;
    shareBubbles.showTwitterBubble = YES;
    shareBubbles.showRedditBubble = YES;
    shareBubbles.showPinterestBubble = YES;

    [shareBubbles addCustomButtonWithIcon:[UIImage imageNamed:@"mail_icon"]
                          backgroundColor:[UIColor colorWithRed:0.0 green:164.0 / 255.0 blue:120.0 / 255.0 alpha:1.0]
                              andButtonId:MAIL_BUTTON_ID];

    [shareBubbles show];
}

- (void)aaShareBubbles:(AAShareBubbles *)shareBubbles tappedBubbleWithType:(int)bubbleType {
    switch (bubbleType) {
        case AAShareBubbleTypeFacebook:
            [self showSharePopup:@"Facebook"];
            break;
        case AAShareBubbleTypeTwitter:
            [self showSharePopup:@"Twitter"];
            break;
        case AAShareBubbleTypeReddit:
            [self showSharePopup:@"Reddit"];
            break;
        case AAShareBubbleTypePinterest:
            [self showSharePopup:@"Pintrest"];
            break;
        case MAIL_BUTTON_ID:
            [self openMailApp];
            break;
        default:
            break;
    }
}

#pragma mark - share functions

- (void)openMailApp {
    NSString *mailUrl = [NSString stringWithFormat:@"mailto:?subject=Check out my photo!&body=%@", self.selectedMedia.link];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailUrl]];
}

- (void)showSharePopup:(NSString *)shareName {
    [UIAlertView showWithTitle:@"Share media"
                       message:[NSString stringWithFormat:@"In a real app this would open %@", shareName]
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {

                      }];
}

@end
