//
//  AcknowledgementsViewController.m
//  nxtbgthngrm
//
//  Created by Michal Thompson on 15/12/14.
//  Copyright (c) 2014 Michal Thompson. All rights reserved.
//

#import "AcknowledgementsViewController.h"

@interface AcknowledgementsViewController ()
@property(weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation AcknowledgementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Pods-acknowledgements" ofType:@"markdown"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.textView.text = content;
}

@end
