//
//  StorePickerController.m
//  Taste
//
//  Created by Piyush Poddar on 8/26/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "StorePickerController.h"
#import "Stores.h"
#import "CameraViewController.h"
#import "Store.h"
#import "AFNetworking.h"
#import "GAIDictionaryBuilder.h"

@interface StorePickerController() <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *selectStore;

@property (strong, nonatomic) Stores *stores;
@property (strong, nonatomic) Store *selectedStore;

@end


@implementation StorePickerController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
    self.whereButton.font = [UIFont fontWithName:@"OpenSans-SemiBold" size:25.0];
    
    //Populate list of stores
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://www.getTaste.co/stores" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        NSError *errStores;
        self.stores = [[Stores alloc] initWithDictionary:responseObject error:&errStores];
        if (errStores) {
            NSLog(@"Unable to initialize List of Participating Stores, %@", errStores.localizedDescription);
        }
        [self.selectStore reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error Getting List of Stores: %@", error);
        // May return nil if a tracker has not already been initialized with a
        // property ID.
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:[NSString stringWithFormat:@"Error getting list of stores: %@", error.localizedDescription]
                        withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
        
    }];
}

- (IBAction)cancel:(id)sender {
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:NULL];

}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.stores.Stores count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedStore = [self.stores.Stores objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"PickStoreToCamera" sender:self];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                          action:@"list_selection"  // Event action (required)
                                                           label:@"storeChosen"          // Event label
                                                           value:[NSNumber numberWithInt:[self.selectedStore.store_id intValue]]] build]];    // Event value
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *toReturn = [tableView dequeueReusableCellWithIdentifier:@"Store Cell"];
    toReturn.textLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
    toReturn.textLabel.text = ((Store *)([self.stores.Stores objectAtIndex:indexPath.row])).store_name;
    
    return toReturn;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PickStoreToCamera"]) {
        if ([segue.destinationViewController isKindOfClass:[CameraViewController class]]) {
            CameraViewController *cvc = [segue destinationViewController];
            cvc.selectedStore = self.selectedStore;
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Store Picker Screen";
}

@end
