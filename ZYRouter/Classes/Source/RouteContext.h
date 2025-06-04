//
//  RouteContext.h
//  ZYRouter
//
//  Created by Young on 2024/12/13.
//

#import <Foundation/Foundation.h>

@class RouteRequest, RouteInterceptor;
@protocol RouteInterceptorProtocol, RouteTaskProtocol;

@protocol RouteProgressProtocol <NSObject>

- (void)routeTaskWillExcute:(id<RouteTaskProtocol>)task;

@end

@interface RouteContext : NSObject <RouteInterceptorProtocol>

@property (nonatomic, readonly) RouteRequest *request;

@property (nonatomic, readonly) NSArray<RouteInterceptor *> *interceptors;
@property (nonatomic, readonly) RouteInterceptor *currentInterceptor;

@property (nonatomic, readonly) id<RouteTaskProtocol> task;

@property (nonatomic, readonly) RouteContext *parentContext;
@property (nonatomic, readonly) NSArray<RouteContext *> *childContexts;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithRequest:(RouteRequest *)request interceptors:(NSArray<RouteInterceptor *> *)interceptors task:(id<RouteTaskProtocol>)task;

- (void)next;
- (void)interrupt;

- (void)addChildContext:(RouteContext *)context;
- (void)removeFromParentContext;

@end
