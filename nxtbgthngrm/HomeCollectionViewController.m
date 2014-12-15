//
//  HomeCollectionViewController.m
//  nxtbgthngrm
//
//  Created by Michal Thompson on 14/12/14.
//  Copyright (c) 2014 Michal Thompson. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "InstagramMedia.h"
#import "ImageViewController.h"
#import "InstagramComment.h"
#import "UIAlertView+Blocks.h"
#import "InstagramPaginationInfo.h"
#import "SVGeocoder.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HomeCollectionViewController ()
@property(weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property(nonatomic) NSMutableArray *collectionViewArray;
@property(nonatomic, assign) CGFloat scale;
@property(nonatomic) BOOL userIsLoggedIn;
@property(nonatomic, strong) InstagramPaginationInfo *currentPaginationInfo;
@end

@implementation HomeCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scale = 1.0;

    self.clearsSelectionOnViewWillAppear = NO;

    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePinchGesture:)];
    [self.collectionView addGestureRecognizer:gesture];

    [self loadImageData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setLoginButtonTitle];
}

- (void)loadImageData {
    self.collectionViewArray = [[NSMutableArray alloc] init];

    //The Instagramkit credentials are stored in Instagramkit.plist
    InstagramEngine *sharedEngine = [InstagramEngine sharedEngine];
    [sharedEngine getSelfFeedWithSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        self.collectionViewArray = [media mutableCopy];
        self.currentPaginationInfo = paginationInfo;
        [self.collectionView reloadData];
        self.userIsLoggedIn = YES;
        [self setLoginButtonTitle];
    }                            failure:^(NSError *error) {
        self.userIsLoggedIn = NO;
        self.collectionViewArray = nil;
        [self.collectionView reloadData];
        [self performSegueWithIdentifier:@"Login" sender:self];
    }];
}

- (void)setLoginButtonTitle {
    if (self.userIsLoggedIn) {
        [self.loginButton setTitle:@"Logout"];
    }
    else {
        [self.loginButton setTitle:@""];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[ImageViewController class]]) {

        // send the whole array, so the imageviewcontroller could implement a swipe view if needed.
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *index = indexPaths[0];
        ((ImageViewController *) [segue destinationViewController]).selectedIndex = index.row;
        ((ImageViewController *) [segue destinationViewController]).mediaArray = self.collectionViewArray;
    } else if ([[segue destinationViewController] isKindOfClass:[LoginViewController class]]) {

        // set delegate so that login view can reload data after successful login
        ((LoginViewController *) [segue destinationViewController]).delegate = self;
    }
}

//if user is logged in, and wants to log out, logout, then perform segue
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"Login"]) {
        if (self.userIsLoggedIn) {
            [UIAlertView showWithTitle:@"logout?"
                               message:@"Do you really want to logout?"
                     cancelButtonTitle:@"NO"
                     otherButtonTitles:@[@"YES"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      NSLog(@"Cancelled");
                                  } else {
                                      InstagramEngine *sharedEngine = [InstagramEngine sharedEngine];
                                      [sharedEngine logout];
                                      [self performSegueWithIdentifier:@"Login" sender:self];
                                  }
                              }];
            return NO;
        }
    }

    return YES;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionViewArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    // get all the views by tags, and set them to blank. I'm fairly sure that this tag system is outdated, and that there is a better way...
    UIImageView *recipeImageView = (UIImageView *) [cell viewWithTag:100];
    recipeImageView.image = nil;
    UILabel *captionLabel = (UILabel *) [cell viewWithTag:200];
    captionLabel.text = @"";
    UILabel *likesLabel = (UILabel *) [cell viewWithTag:300];
    likesLabel.text = @"";
    UILabel *locationLabel = (UILabel *) [cell viewWithTag:400];
    locationLabel.text = @"";
    locationLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Image_Fade_top"]];

    locationLabel.hidden = YES;

    if (self.collectionViewArray.count > indexPath.row) {
        InstagramMedia *media = self.collectionViewArray[(NSUInteger) indexPath.row];

        //if the scale is small enough, just use the thumbnails, otherwise use standard image size.
        if (self.scale <= 1.64) {
            [recipeImageView sd_setImageWithURL:media.thumbnailURL];
        } else {
            [recipeImageView sd_setImageWithURL:media.standardResolutionImageURL];
        }

        captionLabel.text = media.caption.text;
        likesLabel.text = [NSString stringWithFormat:@"%li", (long)media.likesCount];

        // This does a google api check for the coordinates of the InstagramMedia object.
        // It gets called every time the cell is created, so this is veeeery inefficient.
        //TODO: extend the InstagramMedia class, so that it can store actual location names, so we can at least cache them after the first call.
        CLLocationCoordinate2D locationCoordinate2D = media.location;
        [SVGeocoder reverseGeocode:locationCoordinate2D
                        completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
                            if ([placemarks count] > 0) {
                                SVPlacemark *placemark = placemarks[0];
                                locationLabel.text = placemark.locality;
                                locationLabel.hidden = NO;
                                [locationLabel sizeToFit];
                            }
                        }];
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize result = CGSizeMake(200 * self.scale, 200 * self.scale);
    return result;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentPaginationInfo.nextMaxId) {
        if (indexPath.row >= self.collectionViewArray.count - 1) {
            [[InstagramEngine sharedEngine] getSelfFeedWithCount:15 maxId:self.currentPaginationInfo.nextMaxId success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
                self.currentPaginationInfo = paginationInfo;
                NSLog(@"paginationInfo.nextMaxId = %@", paginationInfo.nextMaxId);
                [self.collectionViewArray addObjectsFromArray:media];
                [self.collectionView reloadData];
            }                                            failure:^(NSError *error) {
                NSLog(@"Request Self Feed Failed");
            }];
        }
    }
}

#pragma mark - pinch gesture

- (void)didReceivePinchGesture:(UIPinchGestureRecognizer *)gesture {
    static CGFloat scaleStart;

    if (gesture.state == UIGestureRecognizerStateBegan) {
        scaleStart = self.scale;
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        // don't allow scale to become too small, otherwise images become too small.
        if (scaleStart * gesture.scale > 1) {
            self.scale = scaleStart * gesture.scale;
        }

        // scale > 2 should reload data with larger images.
        if (self.scale > 2) {
            [self.collectionView reloadData];
        }

        if (self.scale > 1) {
            [self.collectionView.collectionViewLayout invalidateLayout];
        }
    }
}

#pragma mark - delegate

- (void)reloadData {
    [self loadImageData];
}

@end
