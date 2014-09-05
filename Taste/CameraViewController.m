//
//  CameraViewController.m
//  Taste
//
//  Created by Piyush Poddar on 8/14/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "CameraViewController.h"
#import "AFNetworking.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Stores.h"
#import "Store.h"
#import "CodeViewController.h"
#import "StorePickerController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GAIDictionaryBuilder.h"

@interface CameraViewController() <UINavigationControllerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *whereOutlet;
@property (strong, nonatomic) UIImage *imageBeforeEdits;
@property (strong, nonatomic) IBOutlet UILabel *selectedStoreField;

@end


@implementation CameraViewController

- (IBAction)sharePicture:(id)sender {
    
    //Check to see if a store was selected
    if (self.selectedStore) {
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                              action:@"button_press"  // Event action (required)
                                                               label:@"sharePicture"          // Event label
                                                               value:@1] build]];    // Event value
        
        
        // Check for publish permissions
        [FBRequestConnection startWithGraphPath:@"/me/permissions"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {

                                  if (!error){
                                      NSArray *permissions= (NSArray *)[result data];
                                      BOOL publishPermissionFound = NO;
                                      
                                      for (int i = 0; i < [permissions count];i++) {
                                          NSDictionary *currentPermission = [permissions objectAtIndex:i];
                                          if ([(NSString *)[currentPermission objectForKey:@"permission"] isEqualToString:@"publish_actions"] && [(NSString *)[currentPermission objectForKey:@"status"] isEqualToString:@"granted"]) {
                                              publishPermissionFound = YES;
                                              break;
                                          }
                                      }
                                      
                                      if (!publishPermissionFound){
                                          // Publish permissions not found, ask for publish_actions
                                          [self requestPublishPermissions];
                                          
                                      } else {
                                          // Publish permissions found, publish the OG story
                                          [self segueToCode];
                                      }
                                      
                                  } else {
                                      // There was an error, handle it
                                      // See https://developers.facebook.com/docs/ios/errors/
                                      NSLog(@"Error in retrieving existing FB permissions: %@",[error localizedDescription]);
                                      // May return nil if a tracker has not already been initialized with a
                                      // property ID.
                                      id tracker = [[GAI sharedInstance] defaultTracker];
                                      
                                      [tracker send:[[GAIDictionaryBuilder
                                                      createExceptionWithDescription:[NSString stringWithFormat:@"Error in retrieving existing FB permissions: %@",[error localizedDescription]] withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
                                  }
                              }];
    }
    else {
        //Alert user to choose a location
        [[[UIAlertView alloc] initWithTitle:@"Location not chosen"
                                    message:@"We don't know where you are!"
                                   delegate:self
                          cancelButtonTitle:@"OK!"
                          otherButtonTitles:nil] show];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                              action:@"button_press"  // Event action (required)
                                                               label:@"shareWithoutStore"          // Event label
                                                               value:@0] build]];    // Event value
        
    }
}

- (void) requestPublishPermissions {
    

    // Request publish_actions
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            __block NSString *alertText;
                                            __block NSString *alertTitle;
                                            if (!error) {
                                                if ([FBSession.activeSession.permissions
                                                     indexOfObject:@"publish_actions"] == NSNotFound){
                                                    // Permission not granted, tell the user we will not publish
                                                    alertTitle = @"Permission not granted";
                                                    alertText = @"Please change your permissions to get your gift!";
                                                    [[[UIAlertView alloc] initWithTitle:alertTitle
                                                                                message:alertText
                                                                               delegate:self
                                                                      cancelButtonTitle:@"OK!"
                                                                      otherButtonTitles:nil] show];
                                                } else {
                                                    // Permission granted, publish the OG story
                                                    [self segueToCode];
                                                }
                                                
                                            } else {
                                                NSLog(@"Error in getting publish permissions: %@",[error localizedDescription]);
                                                
                                                // May return nil if a tracker has not already been initialized with a
                                                // property ID.
                                                id tracker = [[GAI sharedInstance] defaultTracker];
                                                
                                                [tracker send:[[GAIDictionaryBuilder
                                                                createExceptionWithDescription:[NSString stringWithFormat:@"Error in getting publish permissions: %@", error.localizedDescription] withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
                                            }
                                        }];
}

- (void) segueToCode {
    [self performSegueWithIdentifier:@"CameraToCode" sender:self];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"cameraToCode"          // Event label
                                                           value:@1] build]];    // Event value
    
}


- (IBAction) pickedStore:(UIStoryboardSegue *) segue {
    
    if ([segue.identifier isEqualToString:@"PickStoreToCamera"]) {
        if ([segue.sourceViewController isKindOfClass:[StorePickerController class]]) {
            
            self.selectedStoreField.text = self.selectedStore.store_name;
            NSString *textToDraw = [NSString stringWithFormat:@"#%@  #%@",self.selectedStore.hashtag_text,self.selectedStore.hashtag_location];
            [self drawText:textToDraw inImage:self.imageBeforeEdits];
        }
    }
    
}

//- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//
//    return 1;
//};

//- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    
//    //Retrieve list of stores here
//    NSInteger numStores = 3;
//    return numStores;
//    
//}
//
//- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    
//    return [self.stores.Stores objectAtIndex:row];
//};
//
//- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    
//    self.selectedStore = [self.stores.Stores objectAtIndex:row];
//    [self setImage: [CameraViewController drawText:self.selectedStore.store_name inImage:self.imageBeforeEdits]];
//};

- (void) setImageForImageView:(UIImage *)image {
    //self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    NSLog(@"Image height and width: %f by %f",image.size.height, image.size.width);
    self.imageView.image = image;
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.whereOutlet.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:17.0];
    self.messageTextField.font = [UIFont fontWithName:@"OpenSans-Light" size:15.0];
    self.selectedStoreField.font = [UIFont fontWithName:@"OpenSans-Light" size:15.0];
    
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *) kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    //uiipc.allowsEditing = YES;
    [self presentViewController:uiipc animated:YES completion:NULL];
    
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [self dismissViewControllerAnimated:YES completion:NULL];
//    [self.messageTextField becomeFirstResponder];
    
    [[[UIAlertView alloc] initWithTitle:@"No Picture Taken"
                                message:@"Eek, you need to take a picture!"
                               delegate:self
                      cancelButtonTitle:@"Take a Picture"
                      otherButtonTitles:nil] show];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Cancel"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"cancelDuringPicture"          // Event label
                                                           value:@0] build]];    // Event value
    
    UIImagePickerController *uiipc = [[UIImagePickerController alloc] init];
    uiipc.delegate = self;
    uiipc.mediaTypes = @[(NSString *) kUTTypeImage];
    uiipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    //uiipc.allowsEditing = YES;
    //[self presentViewController:uiipc animated:YES completion:NULL];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *returnedImage = info[UIImagePickerControllerEditedImage];
    if (!returnedImage) {
        returnedImage = info[UIImagePickerControllerOriginalImage];
    }
    
    self.imageBeforeEdits = returnedImage;
    //self.image = returnedImage;
    [self setImageForImageView:self.imageBeforeEdits];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.messageTextField becomeFirstResponder];

    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"pictureTaken"          // Event label
                                                           value:@1] build]];    // Event value
  
}

-(void)dismissKeyboard {
    [self.messageTextField resignFirstResponder];
}

-(void) drawText:(NSString *) text
               inImage:(UIImage *) original {
    
    __weak typeof(self) weakSelf = self;
    
    // call the same method on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIFont *font = [UIFont fontWithName: @"OpenSans" size:original.size.height*0.025];
        CGSize size = CGSizeMake(original.size.width, original.size.height);
        
        if ([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f) {
            UIGraphicsBeginImageContextWithOptions(size, NO, 2.0f);
        } else {
            UIGraphicsBeginImageContextWithOptions(size,NO,0.0f);
        }
        
        [original drawInRect:CGRectMake(0,0,original.size.width,original.size.height)];
        
        CGPoint point = CGPointMake((CGFloat) 0.60*(original.size.width/2), (CGFloat) 0.93*original.size.height);
        
        CGRect rect = CGRectMake(point.x, point.y, original.size.width, original.size.height);
        //[[UIColor whiteColor] setFill];
        [text drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor whiteColor]}];
        UIImage *editedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // update UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf setImageForImageView:nil];
                [strongSelf setImageForImageView: editedImage];
            }
            
            
        });
        
    });
    
    
    
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [self.messageTextField resignFirstResponder];
    
    
    // You can access textField.text and do what you need to do with the text here
    
    return YES; // We'll let the textField handle the rest!
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

            if ([segue.identifier isEqualToString:@"CameraToCode"]) {
                if ([segue.destinationViewController isKindOfClass:[CodeViewController class]]) {
                    
                    // Get the UIImage from the image picker controller
                    UIImage* imageToStage = self.imageView.image;
                    
                    // Stage the image
                    [FBRequestConnection startForUploadStagingResourceWithImage:imageToStage completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if(!error) {
                            NSLog(@"Successfuly staged image with staged URI: %@", [result objectForKey:@"uri"]);
                            self.snap.facebook_post_id = [result objectForKey:@"uri"];
                            self.snap.picture_url = [result objectForKey:@"uri"];
                            
                            NSLog(@"Set image uri of snap: %@", [self.snap description]);
                            if (self.snap.access_token) {
                                [self.snap postSnap];
                            }
                        } else {
                            // An error occurred, we need to handle the error
                            // See: https://developers.facebook.com/docs/ios/errors
                            NSLog(@"Error in staging FB image: %@", [error localizedDescription]);
                            // May return nil if a tracker has not already been initialized with a
                            // property ID.
                            id tracker = [[GAI sharedInstance] defaultTracker];
                            
                            [tracker send:[[GAIDictionaryBuilder
                                            createExceptionWithDescription:[NSString stringWithFormat:@"Error in staging FB image: %@", error.localizedDescription] withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
                        }
                    }];
                    
                    
                    self.snap.store = self.selectedStore;
                    self.snap.snap_message = self.messageTextField.text;
                    
                    CodeViewController *controller = segue.destinationViewController;
                    controller.image = self.imageView.image;
                    controller.snap = self.snap;
                }
            }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Edit Image Screen";
}

@end
