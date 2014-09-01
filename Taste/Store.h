//
//  Store.h
//  Taste
//
//  Created by Piyush Poddar on 8/20/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol Store
@end

@interface Store : JSONModel

@property (nonatomic, strong) NSString *store_name;
@property (nonatomic, strong) NSString *store_id;
@property (nonatomic, strong) NSString *hashtag_text;
@property (nonatomic, strong) NSString *hashtag_location;
@property (nonatomic, strong) NSString *store_code;
@property (nonatomic, strong) NSString *store_latitude;
@property (nonatomic, strong) NSString *store_longitude;

@end
