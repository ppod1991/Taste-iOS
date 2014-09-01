//
//  TasteAppDelegate.h
//  Taste
//
//  Created by Piyush Poddar on 8/10/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "loginViewController.h"

@interface TasteAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) loginViewController *customLoginViewController;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

- (void)userLoggedIn;

- (void)userLoggedOut;

@end
