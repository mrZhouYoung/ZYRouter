//
//  LoginInterceptor.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "LoginInterceptor.h"
#import "InterceptorNavigationController.h"
#import "User.h"
#import "ZYRouter.h"

@implementation LoginInterceptor

- (void)checkState:(void (^)(RouteInterceptionState))block {
    if ([User currentUser]) {
        block(RouteInterceptionStateVerified);
    } else {
        block(RouteInterceptionStateUnverified);
    }
}

- (void)verify {
    [self checkState:^(RouteInterceptionState state) {
        switch (state) {
            case RouteInterceptionStateVerified:{
                [self.context next];
            }
                break;
            case RouteInterceptionStatePending:{
                // do something
            }
                break;
            case RouteInterceptionStateUnverified:{
                ZYRouter.URL(@"/login").push().pushFrom([InterceptorNavigationController shared]).parentContext(self.context).route();
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
