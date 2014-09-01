//
//  Promotions.h
//  Taste
//
//  Created by Piyush Poddar on 8/20/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "JSONModel.h"
#import "Promotion.h"

@interface Promotions : JSONModel

@property (strong, nonatomic) NSArray <Promotion> *Promotions;

@end
