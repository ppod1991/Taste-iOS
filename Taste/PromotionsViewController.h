//
//  PromotionsViewController.h
//  Taste
//
//  Created by Piyush Poddar on 8/10/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snap.h"
#import "Promotions.h"
#import "GAITrackedViewController.h"

@interface PromotionsViewController : GAITrackedViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) Promotions *promotions; //Valid and unused promotion objects for the current user
@property (strong, nonatomic) Snap *snap;

@end