//
//  TasteAppDelegate.m
//  Taste
//
//  Created by Piyush Poddar on 8/10/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "TasteAppDelegate.h"
#import "User.h"
#import "Snap.h"
#import "GAIDictionaryBuilder.h"

@interface TasteAppDelegate()
@end

@implementation TasteAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Google analytics initialization
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    //[GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-42931937-2"];
    
    
//    // Override point for customization after application launch.
//    [FBLoginView class];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *storyBoardFile = [bundle objectForInfoDictionaryKey:@"UIMainStoryboardFile"];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:storyBoardFile bundle:bundle];


    //UIStoryboard *storyBoard = [[self.window rootViewController] storyboard];
    
    // Create a LoginUIViewController instance where we will put the login button
//    loginViewController *customLoginViewController = [[loginViewController alloc] init];
    loginViewController *customLoginViewController = [storyBoard instantiateViewControllerWithIdentifier:@"loginViewController"];
    //UIButton *loginButton = [self.customLoginViewController loginButton];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: customLoginViewController];

    navController.navigationBar.barTintColor = [UIColor colorWithRed:50/255.0 green:10/255.0 blue:10/255.0 alpha:1];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    [navController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"OpenSans" size:17.0]}];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"OpenSans-Light" size:16.0]} forState:UIControlStateNormal];
    
    navController.navigationBar.translucent = NO;
    
    self.customLoginViewController = customLoginViewController;
    
    // Set loginUIViewController as root view controller
    self.window.rootViewController = navController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        
    }
    else {
        UIButton *loginButton = [self.customLoginViewController loginButton];
        //[loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
        [[loginButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
        [loginButton setImage:[UIImage imageNamed:@"facebook_login_button"] forState:UIControlStateNormal];
    }
    
    return YES;
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        
        
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
            // May return nil if a tracker has not already been initialized with a
            // property ID.
            id tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:alertTitle withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
            
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // May return nil if a tracker has not already been initialized with a
                // property ID.
                id tracker = [[GAI sharedInstance] defaultTracker];
                
                [tracker send:[[GAIDictionaryBuilder
                                createExceptionWithDescription:@"User cancelled login" withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                
                // May return nil if a tracker has not already been initialized with a
                // property ID.
                id tracker = [[GAI sharedInstance] defaultTracker];
                
                [tracker send:[[GAIDictionaryBuilder
                                createExceptionWithDescription:alertText withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
                
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    // Set the button title as "Log in with Facebook"
    UIButton *loginButton = [self.customLoginViewController loginButton];
    //[loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    [[loginButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [loginButton setImage:[UIImage imageNamed:@"facebook_login_button"] forState:UIControlStateNormal];
    
    // Confirm logout message
    [self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            NSDictionary *userResults = result;
            
            
            NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
           
            NSString *facebook_id = [userResults valueForKey:@"id"];
            [user setObject:facebook_id forKey:@"facebook_id"];
            
            NSString *first_name = [userResults valueForKey:@"first_name"];
            [user setObject:first_name forKey:@"first_name"];
            
            NSString *last_name = [userResults valueForKey:@"last_name"];
            [user setObject:last_name forKey:@"last_name"];
            
            NSString *fb_url = [userResults valueForKey:@"link"];
            [user setObject:fb_url forKey:@"fb_url"];
            
            NSString *email = [userResults valueForKey:@"email"];
            if (email) {
                [user setObject:email forKey:@"email"];
            }
            
            NSString *gender = [userResults valueForKeyPath:@"gender"];
            if (gender) {
                [user setObject:gender forKey:@"gender"];
            }
            
            NSString *location = [userResults valueForKey:@"location"];
            if (location) {
                [user setObject:location forKey:@"location_id"];
            }
            
            NSLog(@"Formed User = %@", [user description]);
            

            

            
            //POST request to add/retrieve the logged in fb user
            [[self.customLoginViewController activityIndicator] startAnimating];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager POST:@"http://www.getTaste.co/users/android" parameters:user success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //Make user model using returned user from database
                NSError *errUser;
                User *userObject = [[User alloc] initWithDictionary:responseObject error:&errUser];
                if (errUser) {
                    NSLog(@"Unable to initialize User Model, %@", errUser.localizedDescription);
                }
                
                Snap *snap = [[Snap alloc] init];
                snap.user = userObject;
                self.customLoginViewController.snap = snap;
                
                
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                
                // You only need to set User ID on a tracker once. By setting it on the tracker, the ID will be
                // sent with all subsequent hits.
                [tracker set:@"&uid"
                       value:userObject.user_id];
                
                
                NSLog(@"JSON: %@", responseObject);
                [self.customLoginViewController performSegueWithIdentifier:@"loginToPromotionsSegue" sender: self.customLoginViewController];
                [[self.customLoginViewController activityIndicator] stopAnimating];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                
                // May return nil if a tracker has not already been initialized with a
                // property ID.
                id tracker = [[GAI sharedInstance] defaultTracker];
                
                [tracker send:[[GAIDictionaryBuilder
                                createExceptionWithDescription:[NSString stringWithFormat:@"Error in adding or retrieving user from database: %@", error.localizedDescription] withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
                
            }];
            
            
            
            
        } else {
            [self showMessage:@"Could not retrieve information from Facebook. Please check your internet connection and Taste app settings" withTitle:@"Error"];
            
            // May return nil if a tracker has not already been initialized with a
            // property ID.
            id tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:@"Could not retrieve information from Facebook. Please check your internet connection and Taste app settings" withFatal:@NO]  build]];  // isFatal (required). NO indicates non-fatal exception.
            
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
    
    // Set the button title as "Log out"
    UIButton *loginButton = self.customLoginViewController.loginButton;
    //[loginButton setTitle:@"Log out" forState:UIControlStateNormal];
    [[loginButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [loginButton setImage:[UIImage imageNamed:@"facebook_logout_button"] forState:UIControlStateNormal];
    //[loginButton setI]

    
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    
//    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
//    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
//    
//    // You can add your app-specific url handling code here if needed
//    
//    return wasHandled;
//}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    // Note this handler block should be the exact same as the handler passed to any open calls.
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         TasteAppDelegate *appDelegate = (TasteAppDelegate *)[UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [appDelegate sessionStateChanged:session state:state error:error];
     }];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}



@end
