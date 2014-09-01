//
//  StorePickerController.h
//  Taste
//
//  Created by Piyush Poddar on 8/26/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface StorePickerController : GAITrackedViewController
@property (strong, nonatomic) IBOutlet UILabel *whereButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;

@end
