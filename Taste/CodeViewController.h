//
//  CodeViewController.h
//  Taste
//
//  Created by Piyush Poddar on 8/18/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snap.h"
#import "GAITrackedViewController.h"

@interface CodeViewController : GAITrackedViewController <UITextFieldDelegate>

@property (strong, nonatomic) Snap *snap;
@property (strong, nonatomic) UIImage *image;

@end
