//
//  RouteContext.m
//  ZYRouter
//
//  Created by Young on 2024/12/13.
//

#import "ZYRouter.h"

@interface RouteContext ()

@end

@implementation RouteContext {
    RouteRequest *_request;
    NSArray *_interceptors;
    id<RouteTaskProtocol> _task;
    
    __weak RouteContext *_parentContext;
    NSMutableArray<RouteContext *> *_childContexts;
    
    NSUInteger _index;
}

- (instancetype)initWithRequest:(RouteRequest *)request interceptors:(NSArray<RouteInterceptor *> *)interceptors task:(id<RouteTaskProtocol>)task {
    if (self = [super init]) {
        _request = request;
        _interceptors = interceptors;
        _task = task;
        
        for (RouteInterceptor *interceptor in interceptors) {
            interceptor.context = self;
        }
        task.context = self;
        
        _childContexts = [NSMutableArray array];
        
        _index = -1;
    }
    return self;
}

- (void)next {
    _index++;
    NSLog(@"拦截器数组长度%ld",self.interceptors.count);
    if (_index < self.interceptors.count) {
        [self.currentInterceptor verify];
    } else {
        for (int i = (int)self.interceptors.count-1; i >= 0; i--) {
            RouteInterceptor *interceptor = [self.interceptors objectAtIndex:i];
            if ([interceptor respondsToSelector:@selector(routeTaskWillExcute:)]) {
                [interceptor routeTaskWillExcute:self.task];
                return;
            }
        }
        [self.task excute];
    }
}

- (void)interceptor:(RouteInterceptor *)interceptor finishedWithState:(RouteInterceptionState)state {
    switch (state) {
        case RouteInterceptionStateVerified:
            [self next];
            break;
        case RouteInterceptionStateUnverified:{
            RouteResponse *response = [[RouteResponse alloc] initWithCode:ResponseCodeInterceptionFailed message:[NSString stringWithFormat:@"interception failed in %@", interceptor]];
            if (self.task.completionHandler) {
                self.task.completionHandler(response);
            }
            [self interrupt];
        }
            break;
        case RouteInterceptionStatePending:{
            RouteResponse *response = [[RouteResponse alloc] initWithCode:ResponseCodeInterceptionPending message:[NSString stringWithFormat:@"interception pending in %@", interceptor]];
            if (self.task.completionHandler) {
                self.task.completionHandler(response);
            }
            [self interrupt];
        }
            break;
        case RouteInterceptionStateUserCancel:{
            RouteResponse *response = [[RouteResponse alloc] initWithCode:ResponseCodeInterceptionCancelled message:[NSString stringWithFormat:@"interception cancelled in %@", interceptor]];
            if (self.task.completionHandler) {
                self.task.completionHandler(response);
            }
            [self interrupt];
        }
            break;
        default:
            break;
    }
}

- (void)interrupt {
    RouteContext *context = self;
    while (context) {
        RouteContext *parent = context.parentContext;
        [context removeFromParentContext];
        context = parent;
    }
}

#pragma mark - child parent
- (void)addChildContext:(RouteContext *)context {
    [_childContexts addObject:context];
    
    [context addedToParentContext:self];
}

- (void)addedToParentContext:(RouteContext *)context {
    _parentContext = context;
}

- (void)removeFromParentContext {
    NSLog(@"从傅移除：%@", self.request.URL);
    if (self.parentContext) {
        [self.parentContext removeChildContext:self];
    } else {
        [ZYRouter removeRouteContext:self];
    }
}

- (void)removeChildContext:(RouteContext *)context {
    [_childContexts removeObject:context];
}

#pragma mark - getter
- (RouteRequest *)request {
    return _request;
}

- (NSArray<RouteInterceptor *> *)interceptors {
    return _interceptors;
}

- (RouteInterceptor *)currentInterceptor {
    if (_interceptors.count > 0 && _index < _interceptors.count) {
        return _interceptors[_index];
    }
    return nil;
}

- (id<RouteTaskProtocol>)task {
    return _task;
}

- (RouteContext *)parentContext {
    return _parentContext;
}

- (NSArray<RouteContext *> *)childContexts {
    return [_childContexts copy];
}

@end
