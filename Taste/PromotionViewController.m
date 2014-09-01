//
//  PromotionViewController.m
//  Taste
//
//  Created by Piyush Poddar on 8/11/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "PromotionViewController.h"
#import "PromotionsViewController.h"
#import "AFNetworking.h"
#import "GAIDictionaryBuilder.h"

@interface PromotionsViewController()


@end

@implementation PromotionViewController

- (IBAction)cancel:(id)sender {
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Cancel"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"cancelRedeemPressed"          // Event label
                                                           value:nil] build]];    // Event value
    
}

//- (void) setStoreName:(NSString *)storeName {
//    _storeName = storeName;
//}
//
//- (void) setDisplayText:(NSString *)displayText {
//    _displayText = displayText;
//    
//}
//
//- (void) setValidityDates:(NSString *)validityDates {
//    _validityDates = validityDates;
//
//}
- (IBAction)redeemPromotion:(id)sender {
    
    //POST request to redeem promotion
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
    NSDictionary *jsonPromotion = [self.promotion toDictionary];
    [manager POST:@"http://www.getTaste.co/promotions/redeem" parameters:jsonPromotion
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              
              NSLog(@"Successful Promotion Redemption Attempt: %@", responseObject);

              
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Taste says:"
                                                              message:(NSString *) [responseObject valueForKey:@"response_message"]
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
              [alert show];
              id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
              
              [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                                    action:@"button_press"  // Event action (required)
                                                                     label:@"promotionRedeemed"          // Event label
                                                                     value:@1] build]];    // Event value
              
              [self performSegueWithIdentifier:@"PromotionToPromotions" sender:self];
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error trying to redeem promotion: %@", error.description);
              [self performSegueWithIdentifier:@"PromotionToPromotions" sender:self];
              
              // May return nil if a tracker has not already been initialized with a
              // property ID.
              id tracker = [[GAI sharedInstance] defaultTracker];
              
              [tracker send:[[GAIDictionaryBuilder
                              createExceptionWithDescription:[NSString stringWithFormat:@"Error trying to redeem promotion: %@", error.localizedDescription] withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.

          }];
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //Change fonts to Open-Sans
    self.display_text.font = [UIFont fontWithName:@"OpenSans-Light" size:25.0];
    self.store_name.font = [UIFont fontWithName:@"OpenSans" size:30.0];
    self.validity_dates.font = [UIFont fontWithName:@"OpenSans-Light" size:11.0];
    self.redeemInstructions.font = [UIFont fontWithName:@"OpenSans-Light" size:11.0];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
    
    
    self.display_text.numberOfLines = 0;
    self.store_name.numberOfLines = 0;
    
    [self.store_name setText:[self.promotion valueForKey:@"store_name"]];
    [self.display_text setText:[self.promotion valueForKey:@"display_text"]];
    
    NSString *start = [self.promotion valueForKey:@"start_date"];
    NSString *end = [self.promotion valueForKey:@"end_date"];
    
    NSDateFormatter* df_utc = [[NSDateFormatter alloc] init];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    
    [df_local setTimeZone:currentTimeZone];
    [df_local setDateFormat:@"M/d/YY"];
    NSDate *startDateUTC = [df_utc dateFromString:start];
    NSString *startDateLocal = [df_local stringFromDate:startDateUTC];
    
    NSDate *endDateUTC = [df_utc dateFromString:end];
    NSString *endDateLocal = [df_local stringFromDate:endDateUTC];
    
    [self.validity_dates setText:[NSString stringWithFormat:@"valid %@ to %@", startDateLocal, endDateLocal]];
}

//- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if ([segue.identifier isEqualToString:@"PromotionToPromotions"]) {
//        if ([segue.destinationViewController isKindOfClass:[PromotionsViewController class]]) {
//            PromotionsViewController *controller = segue.destinationViewController;
//            controller.snap = self.snap;
//        }
//    }
//    
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Redeem Promotion Screen";
}

@end
