//
//  Snap.h
//  Taste
//
//  Created by Piyush Poddar on 8/20/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "Store.h"
#import "User.h"
#import "Promotion.h"

@interface Snap : JSONModel

@property (nonatomic, strong) Store *store;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Promotion *promotion;
@property (nonatomic, strong) NSString *access_token;
@property (nonatomic, strong) NSString *picture_url;
@property (nonatomic, strong) NSString *facebook_post_id;
@property (nonatomic, strong) NSString *snap_message;

- (void) postSnap;


@end
