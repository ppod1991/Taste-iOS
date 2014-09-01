//
//  PromotionViewController.h
//  Taste
//
//  Created by Piyush Poddar on 8/11/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promotion.h"
#import "GAITrackedViewController.h"

@interface PromotionViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UILabel *store_name;
@property (strong, nonatomic) IBOutlet UILabel *validity_dates;
@property (strong, nonatomic) IBOutlet UILabel *display_text;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UILabel *redeemInstructions;

@property (nonatomic, strong) Promotion *promotion;

@end
