//
//  InterceptorB.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "InterceptorB.h"
#import "InterceptorNavigationController.h"
#import "User.h"

@implementation InterceptorB

- (void)checkState:(void (^)(RouteInterceptionState))block {
    User *user = [User currentUser];
    
    switch (user.b.intValue) {
        case -1:
        block(RouteInterceptionStatePending);
        break;
        case 0:
        block(RouteInterceptionStateUnverified);
        break;
        case 1:
        block(RouteInterceptionStateVerified);
        break;
        default:
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
            case RouteInterceptionStatePending:{
                // do something
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的信息已提交，暂时无法进行相关操作，请耐心等待审核..." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alert addAction:action];
                [[UIViewController zy_topMostViewControllerOf:[UIApplication sharedApplication].delegate.window.rootViewController] presentViewController:alert animated:YES completion:nil];
            }
                break;
            case RouteInterceptionStateUnverified:{
                ZYRouter.URL(@"/interceptorB").push().pushFrom([InterceptorNavigationController shared]).parentContext(self.context).route();
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
