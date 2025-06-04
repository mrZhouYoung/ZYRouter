//
//  InterceptorC.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "InterceptorC.h"
#import "InterceptorNavigationController.h"
#import "User.h"
#import "ZYRouter.h"

@implementation InterceptorC

- (void)checkState:(void (^)(RouteInterceptionState))block {
    User *user = [User currentUser];
    
    switch (user.c.intValue) {
        case 0:
            block(RouteInterceptionStateUnverified);
            break;
        case 1:
            block(RouteInterceptionStateVerified);
            break;
        default:
            block(RouteInterceptionStateUnverified);
            break;
    }
}

- (void)verify {
    [self checkState:^(RouteInterceptionState state) {
        switch (state) {
            case RouteInterceptionStateVerified:{
                [self.context next];
            }
                break;
            case RouteInterceptionStatePending:
                // do something
                break;
            case RouteInterceptionStateUnverified:{
                ZYRouter.URL(@"/interceptorC").push().pushFrom([InterceptorNavigationController shared]).parentContext(self.context).route();
            }
                break;
            default:{
                // error
            }
                break;
        }
    }];
}

@end
