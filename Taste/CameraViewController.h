//
//  CameraViewController.h
//  Taste
//
//  Created by Piyush Poddar on 8/14/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snap.h"
#import "GAITrackedViewController.h"

@interface CameraViewController : GAITrackedViewController

@property (strong, nonatomic) Snap *snap;
@property (strong, nonatomic) Store *selectedStore;

@end
