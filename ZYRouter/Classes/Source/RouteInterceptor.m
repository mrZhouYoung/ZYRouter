//
//  JHRouteInterceptor.m
//  ZYRouter
//
//  Created by Young on 2024/12/13.
//

#import "ZYRouter.h"
#import "RouteContext.h"

@implementation RouteInterceptor

- (void)checkState:(void (^)(RouteInterceptionState))block {
    block(RouteInterceptionStateUnverified);
}

- (void)successBeforeVerify {
    [self.context next];
}
- (void)pendingBeforeVerify {
    [self.context interceptor:self finishedWithState:RouteInterceptionStatePending];
}
- (void)failureBeforeVerify {
    [self.context interceptor:self finishedWithState:RouteInterceptionStateUnverified];
}

- (void)verify {
    [self checkState:^(RouteInterceptionState state) {
        switch (state) {
            case RouteInterceptionStateVerified:{
                [self successBeforeVerify];
            }
                break;
            case RouteInterceptionStatePending:{
                [self pendingBeforeVerify];
            }
                break;
            case RouteInterceptionStateUnverified:{
                [self failureBeforeVerify];
            }
                break;
            default:{
                [self failureBeforeVerify];
            }
                break;
        }
    }];
}

- (void)successAfterVerify {
    [self.context next];
}
- (void)pendingAfterVerify {
    [self.context interceptor:self finishedWithState:RouteInterceptionStatePending];
}
- (void)failureAfterVerify {
    [self.context interceptor:self finishedWithState:RouteInterceptionStateUnverified];
}

- (void)verified {
    [self checkState:^(RouteInterceptionState state) {
        switch (state) {
            case RouteInterceptionStateVerified:{
                [self successAfterVerify];
            }
                break;
            case RouteInterceptionStateUnverified:{
                [self failureAfterVerify];
            }
                break;
            case RouteInterceptionStatePending:{
                [self pendingAfterVerify];
            }
                break;
            default:{
                [self failureAfterVerify];
            }
                break;
        }
    }];
}

@end
