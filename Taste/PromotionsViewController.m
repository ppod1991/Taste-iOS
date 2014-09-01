//
//  PromotionsViewController.m
//  Taste
//
//  Created by Piyush Poddar on 8/10/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "PromotionsViewController.h"
#import "PromotionViewController.h"
#import "AFNetworking.h"
#import "Promotions.h"
#import "CameraViewController.h"
#import "GAIDictionaryBuilder.h"

@interface PromotionsViewController() <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation PromotionsViewController


- (void) setPromotions:(Promotions *)promotions {
    _promotions = promotions;
    [self.tableView reloadData];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.nameLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:11.0];
    self.nameLabel.text = [NSString stringWithFormat:@"Gifts for %@:",self.snap.user.first_name];
    // Initialize Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Configure Refresh Control
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    // Configure View Controller
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl beginRefreshing];
    
//    [[self.imageButton imageView] setContentMode:UIViewContentModeScaleAspectFit];
//    
//
//    UIImage *cameraButtonImage = [UIImage imageNamed:@"camera_button_main"];
//    [self.imageButton setBackgroundImage:cameraButtonImage forState:UIControlStateNormal];
//    
//    //[self.imageButton setImageEdgeInsets:UIEdgeInsetsMake(1000,1000,1000,1000)];
//    [self.imageButton setBackgroundImage:[UIImage imageNamed:@"camera_button_main_pushed"] forState:UIControlStateSelected];
    
     
    [self getPromotions];
}



- (void) refresh:(id) sender {
    NSLog(@"Refreshing");
    [self.refreshControl beginRefreshing];
    [self getPromotions];
}

- (void) getPromotions {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *promotionsParams = @{@"user_id":self.snap.user.user_id, @"use_status":@"not used"};
    [manager GET:@"http://www.getTaste.co/promotions" parameters:promotionsParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSError *errPromotions;
        self.promotions = [[Promotions alloc] initWithDictionary:responseObject error:&errPromotions];
        NSLog(@"Promotions contains: %@", self.promotions.description);
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
        
        if (errPromotions) {
                NSLog(@"Unable to initialize List of Valid Promotions, %@", errPromotions.localizedDescription);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self.refreshControl endRefreshing];
        
        // May return nil if a tracker has not already been initialized with a
        // property ID.
        id tracker = [[GAI sharedInstance] defaultTracker];
        
        [tracker send:[[GAIDictionaryBuilder
                        createExceptionWithDescription:[NSString stringWithFormat:@"Error retrieving your promotions: %@", error.localizedDescription] withFatal:@NO] build]];  // isFatal (required). NO indicates non-fatal exception.
        
    }];
    
//
//    NSURL *url = [NSURL URLWithString:@"http://www.getTaste.co/promotions?user_id=5"];
//    NSData *jsonResults = [NSData dataWithContentsOfURL:url];
//    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults options:0 error:NULL];
//    NSLog(@"Promotion Results = %@", propertyListResults);
//    self.promotions = [propertyListResults valueForKeyPath:@"Promotions"];
    


    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.promotions.Promotions count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"Promotion Table Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    Promotion *promotion = self.promotions.Promotions[indexPath.row];
    cell.textLabel.text = promotion.store_name;
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:19.0];
    
    cell.detailTextLabel.text = promotion.display_text;
    cell.detailTextLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13.0];
    
    return cell;
    
}

- (IBAction)refreshPromotions:(id)sender {
    
    [self getPromotions];
    
}




- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"PromotionsToPromotion"]) {
                if ([segue.destinationViewController isKindOfClass:[PromotionViewController class]]) {
                    PromotionViewController *controller = segue.destinationViewController;
                    controller.promotion = self.promotions.Promotions[indexPath.row];
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                                          action:@"list_selection"  // Event action (required)
                                                                           label:@"toPromotionPressed"          // Event label
                                                                           value:[NSNumber numberWithInt:[controller.promotion.promotion_id intValue]]] build]];    // Event value
                    
                }
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"PromotionsToCamera"] || [segue.identifier isEqualToString:@"PromotionsToCameraImageButton"]) {
        if ([segue.destinationViewController isKindOfClass:[CameraViewController class]]) {
            CameraViewController *controller = segue.destinationViewController;
            controller.snap = self.snap;
            
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Progress"     // Event category (required)
                                                                  action:@"button_press"  // Event action (required)
                                                                   label:@"toCameraPressed"          // Event label
                                                                   value:nil] build]];    // Event value
        }
    }

}

- (IBAction) redeemedPromotion:(UIStoryboardSegue *) segue {
    
    [self getPromotions];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Promotions Screen";
}

@end
