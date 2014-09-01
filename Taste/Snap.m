//
//  Snap.m
//  Taste
//
//  Created by Piyush Poddar on 8/20/14.
//  Copyright (c) 2014 Piyush Poddar. All rights reserved.
//

#import "Snap.h"
#import "AFNetworking.h"

@implementation Snap

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void) postSnap {
    //POST request to add a new snap
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/html",@"application/json"]];
    NSDictionary *jsonSnap = [self toDictionary];
    NSLog(@"The jsonSnap is: %@", [jsonSnap description]);
    [manager POST:@"http://www.getTaste.co/snaps" parameters:jsonSnap
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSLog(@"Successful Snap Post: %@", responseObject);

        //Clear snap contents
        self.store = nil;
        self.promotion = nil;
        self.picture_url = nil;
        self.snap_message = nil;
        self.facebook_post_id = nil;
        self.access_token = nil;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error posting snap: %@", error.description);
    }];
}

@end
