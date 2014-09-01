//
//  loginViewController.h
//  Taste
//
//  Created by Piyush Poddar on 8/19/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snap.h"
#import "GAITrackedViewController.h"

@interface loginViewController : GAITrackedViewController

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) Snap *snap;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
