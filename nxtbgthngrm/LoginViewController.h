//
//  LoginViewController.h
//  nxtbgthngrm
//
//  Created by Michal Thompson on 14/12/14.
//  Copyright (c) 2014 Michal Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramEngine.h"

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController <UIWebViewDelegate>
@property(nonatomic, assign) IKLoginScope scope;
@property(nonatomic, weak) id <LoginViewControllerDelegate> delegate;
@end

@protocol LoginViewControllerDelegate <NSObject>

- (void)reloadData;

@end