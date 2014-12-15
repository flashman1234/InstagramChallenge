//
//  LoginViewController.m
//  nxtbgthngrm
//
//  Created by Michal Thompson on 14/12/14.
//  Copyright (c) 2014 Michal Thompson. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "LoginViewController.h"
#import "InstagramEngine.h"

@interface LoginViewController ()
@property(weak, nonatomic) IBOutlet UIWebView *loginWebView;
@property(nonatomic) MBProgressHUD *mbProgressHUD;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadWebView];
}

// load webview with instagram login
- (void)loadWebView {
    self.scope = IKLoginScopeRelationships | IKLoginScopeComments | IKLoginScopeLikes;
    self.loginWebView.delegate = self;
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSString *scopeString = [InstagramEngine stringForScope:self.scope];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey], scopeString]];
    [self.loginWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

#pragma mark - webview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    // if the user has logged in, the instagram api will redirect to a new age, which has the access_token parameter in the url.
    // if the access_token exists, save to NSUserDefaults, reload the home collectionview, and then pop.
    NSString *URLString = [request.URL absoluteString];
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            NSString *accessToken = [components lastObject];

            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"accessToken"];
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];

            id <LoginViewControllerDelegate> strongDelegate = self.delegate;
            if ([strongDelegate respondsToSelector:@selector(reloadData)]) {
                [strongDelegate reloadData];
            }

            [self.navigationController popViewControllerAnimated:YES];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.mbProgressHUD hide:YES];
}


@end
