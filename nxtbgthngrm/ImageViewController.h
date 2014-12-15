//
//  ImageViewController.h
//  nxtbgthngrm
//
//  Created by Michal Thompson on 14/12/14.
//  Copyright (c) 2014 Michal Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwipeView/SwipeView.h>
#import <AAShareBubbles/AAShareBubbles.h>
#import "HomeCollectionViewController.h"

@class InstagramMedia;

@interface ImageViewController : UIViewController <AAShareBubblesDelegate>

@property(nonatomic) NSArray *mediaArray;
@property(nonatomic) NSInteger selectedIndex;

@end
