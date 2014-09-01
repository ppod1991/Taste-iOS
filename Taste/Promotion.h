//
//  Promotion.h
//  Taste
//
//  Created by Piyush Poddar on 8/20/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "JSONModel.h"

@protocol Promotion
@end

@interface Promotion : JSONModel

@property (nonatomic, strong) NSString *promotion_id;
@property (nonatomic, strong) NSString *store_id;
@property (nonatomic, strong) NSString *start_date;
@property (nonatomic, strong) NSString *end_date;
@property (nonatomic, strong) NSString *display_text;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *store_name;

@end



