//
//  RouteInterceptor.h
//  ZYRouter
//
//  Created by Young on 2024/12/13.
//

#import <Foundation/Foundation.h>

@class RouteContext, RouteInterceptor;
@protocol RouteProgressProtocol;

typedef NS_ENUM(NSUInteger, RouteInterceptionState) {
    RouteInterceptionStateUnverified,   // 未通过
    RouteInterceptionStateVerified,     // 通过
    RouteInterceptionStatePending,      // 审核中
    RouteInterceptionStateUserCancel    // 用户取消
};

@protocol RouteInterceptorProtocol <NSObject>

- (void)interceptor:(RouteInterceptor *)interceptor finishedWithState:(RouteInterceptionState)state;

@end

@interface RouteInterceptor : NSObject <RouteProgressProtocol>

@property (nonatomic, weak) RouteContext *context;
@property (nonatomic, strong) NSDictionary *options;

- (void)checkState:(void (^)(RouteInterceptionState state))block;

- (void)verify;
- (void)verified;

- (void)successBeforeVerify;
- (void)pendingBeforeVerify;
- (void)failureBeforeVerify;

- (void)successAfterVerify;
- (void)pendingAfterVerify;
- (void)failureAfterVerify;

@end
