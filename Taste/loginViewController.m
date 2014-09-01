//
//  loginViewController.m
//  Taste
//
//  Created by Piyush Poddar on 8/19/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "loginViewController.h"
#import <FacebookSDK/FacebookSDK.h>

#import "TasteAppDelegate.h"
#import "PromotionsViewController.h"


#import "GAIDictionaryBuilder.h"

@interface loginViewController() 
@end

@implementation loginViewController

- (IBAction)toGiftsClicked:(id)sender {
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        [self performSegueWithIdentifier:@"loginToPromotionsSegue" sender:self];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                              action:@"button_press"  // Event action (required)
                                                               label:@"toGifts"          // Event label
                                                               value:@1] build]];    // Event value
        
        
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Not Logged In"
                                    message:@"Please log in to see your gifts"
                                   delegate:self
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil] show];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                              action:@"button_press"  // Event action (required)
                                                               label:@"toGifts"          // Event label
                                                               value:@0] build]];    // Event value
        
        
    }
    
}


//- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
//    NSLog(@"Logged in User %@", user.name);
//    
//}
- (IBAction)loginButtonClick:(id)sender {
    
    NSLog(@"Log in button touched");
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"loginPressed"          // Event label
                                                           value:nil] build]];    // Event value
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        

        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             TasteAppDelegate* appDelegate = (TasteAppDelegate *) [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }

    
}


- (void) viewDidLoad {
    [super viewDidLoad];
    NSLog(@"loginViewController did load");
    
    //[[self.loginButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    
//    
//    [[UILabel appearance] setFont:[UIFont fontWithName:@"OpenSans-Light" size:17.0]];
//    [[UIButton appearance] setFont:[UIFont fontWithName:@"OpenSans-Light" size:17.0]];
    
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"loginToPromotionsSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        
        navController.navigationBar.barTintColor = [UIColor colorWithRed:50/255.0 green:10/255.0 blue:10/255.0 alpha:1];
        navController.navigationBar.tintColor = [UIColor whiteColor];
        [navController.navigationBar
         setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"OpenSans" size:17.0]}];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
         @{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Light" size:16.0]} forState:UIControlStateNormal];
        
        navController.navigationBar.translucent = NO;
        
        
        PromotionsViewController *pvc = navController.viewControllers[0];
        pvc.snap = self.snap;
    }
}

- (IBAction) logoutPushed:(UIStoryboardSegue *) segue {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"toLogoutPressed"          // Event label
                                                           value:nil] build]];    // Event value
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Login Screen";
}

@end
