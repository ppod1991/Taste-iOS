//
//  CodeViewController.m
//  Taste
//
//  Created by Piyush Poddar on 8/18/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "CodeViewController.h"
#import "PromotionsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"
#import "Promotion.h"
#import "GAIDictionaryBuilder.h"

@interface CodeViewController()

@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CodeViewController


- (IBAction)verifyCode:(id)sender {
    NSString *enteredCode = self.codeTextField.text;
    self.codeTextField.text = @"";
    
    if ([enteredCode isEqualToString:self.snap.store.store_code]) {
        //POST a newly earned promotion
        Promotion *promotionToPost = [[Promotion alloc] init];
        promotionToPost.user_id = self.snap.user.user_id;
        promotionToPost.store_id = self.snap.store.store_id;
        NSDictionary *promotionToPostDictionary = [promotionToPost toDictionary];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                              action:@"code_entered"  // Event action (required)
                                                               label:@"Correct Code Entered"          // Event label
                                                               value:nil] build]];    // Event value
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:@"http://www.getTaste.co/promotions" parameters:promotionToPostDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSError *errPromotion;
            NSLog(@"JSON of Successful Posted Promotion: %@", responseObject);
            self.snap.promotion = [[Promotion alloc] initWithDictionary:responseObject error:&errPromotion];
            NSString *fbAccessToken = [FBSession activeSession].accessTokenData.accessToken;
            self.snap.access_token = fbAccessToken;
            
            NSLog(@"Set access token of snap: %@",[self.snap description]);
            if (self.snap.picture_url) {
                [self.snap postSnap];
            };
            
            if (errPromotion) {
                NSLog(@"Error converting posted promotion to Promotion Object: %@", [errPromotion localizedDescription]);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error posting promotion: %@", [error localizedDescription]);
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder
                            createExceptionWithDescription:[NSString stringWithFormat:@"Error posting new promotion: %@",error.localizedDescription]
                            withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
            
        }];
        
        
        
        
        [self performSegueWithIdentifier:@"CodeToPromotions" sender:self];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Code"
                                                        message:@"Please show your phone to an employee!"
                                                       delegate:nil
                                              cancelButtonTitle:@"Retry"
                                              otherButtonTitles:nil];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                              action:@"code_entered"  // Event action (required)
                                                               label:@"Incorrect Code Entered"          // Event label
                                                               value:nil] build]];    // Event value
        [alert show];
    }
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self.codeTextField becomeFirstResponder];
    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.codeTextField.secureTextEntry = YES;
    self.codeTextField.font = [UIFont fontWithName:@"OpenSans-Light" size:15.0];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"CodeToPromotions"]) {
        if ([segue.destinationViewController isKindOfClass:[PromotionsViewController class]]) {
            PromotionsViewController *controller = segue.destinationViewController;
            controller.snap = self.snap;
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Code Verification Screen";
}

@end
