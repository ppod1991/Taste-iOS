//
//  User.h
//  Taste
//
//  Created by Piyush Poddar on 8/20/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "JSONModel.h"

@interface User : JSONModel

@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *facebook_id;
@property (nonatomic, strong) NSString *location_id;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *fb_url;

@end
