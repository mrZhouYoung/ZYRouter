//
//  RouteContextMaker.m
//  ZYRouter
//
//  Created by Young on 2024/12/21.
//

#import "ZYRouter.h"
#import <objc/runtime.h>

@implementation RouteContextMaker {
    RouteMatcher *_matcher;
    
    NSDictionary *_routes;
    NSString *_URL;
    NSString *_redirectFrom;
    NSDictionary *_params;
    
    BOOL _overwritePresent;
    BOOL _present;
    Class _wrapIn;
    UIViewController *_pushFrom;
    
    BOOL _removeAllInterceptors;
    NSArray<RouteInterceptor *> *_interceptors;
    NSArray<Class> *_removeInterceptors;
    NSArray<Class> *_appendInterceptors;
    NSArray<NSDictionary *> *_appendInterceptorOptions;
    NSArray<NSNumber *> *_appendInterceptorIndexes;
    
    Class _taskClass;
    NSDictionary *_taskOptions;
    
    void (^_completionHandler)(RouteResponse *);
    
    RouteContext *_parentContext;
}

- (instancetype)initWithURL:(NSString *)URL matcher:(RouteMatcher *)matcher {
    if (self = [super init]) {
        _URL = URL;
        _matcher = matcher;
    }
    return self;
}

- (RouteContextMaker *(^)(NSString *))redirectFrom {
    return ^RouteContextMaker *(NSString *redirect) {
        self->_redirectFrom = redirect;
        return self;
    };
}

- (RouteContextMaker *(^)(NSDictionary *))params {
    return ^RouteContextMaker *(NSDictionary *params) {
        self->_params = params;
        return self;
    };
}

- (RouteContextMaker *(^)(void))present {
    return ^RouteContextMaker *() {
        self->_overwritePresent = YES;
        self->_present = YES;
        return self;
    };
}

- (RouteContextMaker *(^)(Class))wrapIn {
    return ^RouteContextMaker *(Class c) {
        self->_wrapIn = c;
        return self;
    };
}

- (RouteContextMaker *(^)(void))push {
    return ^RouteContextMaker *() {
        self->_overwritePresent = YES;
        self->_present = NO;
        return self;
    };
}

- (RouteContextMaker *(^)(UIViewController *))pushFrom {
    return ^RouteContextMaker *(UIViewController *pushFrom) {
        self->_pushFrom = pushFrom;
        return self;
    };
}

- (RouteContextMaker *(^)(void))removeAllInterceptors {
    return ^RouteContextMaker *() {
        self->_removeAllInterceptors = YES;
        return self;
    };
}

- (RouteContextMaker *(^)(NSArray<Class> *))removeInterceptors {
    return ^RouteContextMaker *(NSArray *removeInterceptors) {
        self->_removeInterceptors = removeInterceptors;
        return self;
    };
}

- (RouteContextMaker *(^)(NSArray<Class> *))appendInterceptors {
    return ^RouteContextMaker *(NSArray *appendInterceptors) {
        self->_appendInterceptors = appendInterceptors;
        return self;
    };
}

- (RouteContextMaker *(^)(NSArray<NSDictionary *> *))appendInterceptorOptions {
    return ^RouteContextMaker *(NSArray *appendInterceptorOptions) {
        self->_appendInterceptorOptions = appendInterceptorOptions;
        return self;
    };
}

- (RouteContextMaker *(^)(NSArray<NSNumber *> *))appendInterceptorIndexes {
    return ^RouteContextMaker *(NSArray *appendInterceptorIndexes) {
        self->_appendInterceptorIndexes = appendInterceptorIndexes;
        return self;
    };
}

- (RouteContextMaker *(^)(__unsafe_unretained Class))taskClass {
    return ^RouteContextMaker *(__unsafe_unretained Class taskClass) {
        self->_taskClass = taskClass;
        return self;
    };
}

- (RouteContextMaker *(^)(NSDictionary *))taskOptions {
    return ^RouteContextMaker *(NSDictionary *taskOptions) {
        self->_taskOptions = taskOptions;
        return self;
    };
}

- (RouteContextMaker *(^)(void (^)(RouteResponse *)))defaultCompletionHandler {
    return ^RouteContextMaker *(void (^defaultCompletionHandler)(RouteResponse *)) {
        if (!self->_completionHandler) {
            self->_completionHandler = [defaultCompletionHandler copy];
        }
        return self;
    };
}

- (RouteContextMaker *(^)(void (^)(RouteResponse *)))completionHandler {
    return ^RouteContextMaker *(void (^completionHandler)(RouteResponse *)) {
        self->_completionHandler = [completionHandler copy];
        return self;
    };
}

- (RouteContextMaker *(^)(RouteContext *))parentContext {
    return ^RouteContextMaker *(RouteContext *parentContext) {
        self->_parentContext = parentContext;
        return self;
    };
}

- (BOOL (^)(void))route {
    return ^BOOL{
        NSString *patternURL = [self->_matcher patternForURL:self->_URL params:self->_params];
        if (patternURL) {
            [self makeWithPatternURL:patternURL];
            return YES;
        } else {
            [self errorWithResponseCode:ResponseCodeURLNotFound message:[NSString stringWithFormat:@"URL not found: %@", self->_URL]];
            return NO;
        }
    };
}

- (void)makeWithPatternURL:(NSString *)patternURL {
    // 路由参数params
    NSMutableDictionary *params = [[_matcher paramsInPatternURL:patternURL withURL:_URL] mutableCopy];
    if (_params) {
        [params addEntriesFromDictionary:_params];
    }
    
    // 拦截器interceptors
    NSError *interceptorError;
    NSArray *arr = [_matcher interceptorsForPatternURL:patternURL error:&interceptorError];
    if (interceptorError) {
        [self errorWithResponseCode:ResponseCodeInterceptorInstantiateError message:[NSString stringWithFormat:@"cannot instantiate interceptor for URL: %@ in %@", _URL, interceptorError.userInfo[@"message"]]];
        return;
    }
    NSMutableArray *interceptors = [NSMutableArray array];
    if (_interceptors.count) {
        [interceptors addObjectsFromArray:_interceptors];
    }
    [interceptors addObjectsFromArray:arr];
    
    if (_removeAllInterceptors) {
        [interceptors removeAllObjects];
    } else {
        if (_removeInterceptors.count) {
            NSMutableArray *tmp = [interceptors mutableCopy];
            for (RouteInterceptor *interceptor in tmp) {
                for (Class c in _removeInterceptors) {
                    if ([interceptor isKindOfClass:c]) {
                        [interceptors removeObject:interceptor];
                        break;
                    }
                }
            }
        }
        if (_appendInterceptors.count) {
            NSMutableArray *tmp = [NSMutableArray array];
            for (int i = 0; i < 100; i++) {
                [tmp addObject:@(0)];
            }
            
            for (NSUInteger index = 0; index < _appendInterceptors.count; index++) {
                Class c = _appendInterceptors[index];
                RouteInterceptor *interceptor = [[c alloc] init];
                if (!interceptor) {
                    [self errorWithResponseCode:ResponseCodeInterceptorInstantiateError message:[NSString stringWithFormat:@"cannot instantiate interceptor from class: %@ for URL: %@", c, _URL]];
                    return;
                }
                if (index < _appendInterceptorOptions.count && _appendInterceptorOptions[index]) {
                    interceptor.options = _appendInterceptorOptions[index];
                }
                int targetIndex = _appendInterceptorIndexes[index].intValue;
                [tmp replaceObjectAtIndex:targetIndex withObject:interceptor];
            }
            
            for (NSUInteger index = 0; index < interceptors.count; index++) {
                RouteInterceptor *interceptor = interceptors[index];
                NSUInteger targetIndex = [tmp indexOfObject:@(0)];
                [tmp replaceObjectAtIndex:targetIndex withObject:interceptor];
            }
            
            [interceptors removeAllObjects];
            for (id obj in tmp) {
                if (![obj isEqual:@(0)]) {
                    [interceptors addObject:obj];
                }
            }
        }
    }
    _interceptors = interceptors;
    
    // 重定向redirect
    NSString *redirect = [_matcher redirectURLForPatternURL:patternURL];
    if (redirect) {
        [self redirectTo:redirect withParams:params];
        return;
    }
    
    // task
    NSError *taskError;
    id<RouteTaskProtocol> task = [_matcher routeTaskForPatternURL:patternURL error:&taskError];
    if (taskError) {
        [self errorWithResponseCode:ResponseCodeTaskInstantiateError message:[NSString stringWithFormat:@"cannot instantiate task object for URL: %@ in %@", _URL, taskError.userInfo[@"message"]]];
        return;
    }
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:task.options ?: @{}];
    if (_overwritePresent) {
        [options setValue:@(_present) forKey:RoutesControllerPresentKey];
    }
    if (_pushFrom) {
        [options setValue:_pushFrom forKey:RoutesControllerPushFromKey];
    }
    if (_wrapIn) {
        [options setValue:NSStringFromClass(_wrapIn) forKey:RoutesControllerWrapClassKey];
    }
    task.options = options;
    task.params = params;
    task.completionHandler = [_completionHandler copy];
    
    // 路由请求request
    RouteRequest *request = [[RouteRequest alloc] init];
    request.URL = _URL;
    request.redirectFrom = _redirectFrom;
    request.params = params;
    
    // 创建context
    RouteContext *context = [[RouteContext alloc] initWithRequest:request interceptors:interceptors task:task];
    NSLog(@"创建context：%@", _URL);
    if (_parentContext) {
        [_parentContext addChildContext:context];
    } else {
        [ZYRouter addRouteContext:context];
    }
    
    [context next];
}

- (void)redirectTo:(NSString *)redirect withParams:(NSDictionary *)params {
    _params = params;
    _redirectFrom = _URL;
    _URL = redirect;
    _removeAllInterceptors = NO;
    _removeInterceptors = nil;
    _appendInterceptors = nil;
    _appendInterceptorOptions = nil;
    _appendInterceptorIndexes = nil;
    _overwritePresent = NO;
    _present = NO;
    _wrapIn = nil;
    _pushFrom = nil;
    
    NSString *patternURL = [_matcher patternForURL:_URL params:_params];
    if (patternURL) {
        [self makeWithPatternURL:patternURL];
    } else {
        [self errorWithResponseCode:ResponseCodeURLNotFound message:[NSString stringWithFormat:@"URL not found: %@", _URL]];
    }
}

- (void)errorWithResponseCode:(ResponseCode)code message:(NSString *)message {
    RouteResponse *response = [[RouteResponse alloc] initWithCode:code message:message];
    
    if (_completionHandler) {
        _completionHandler(response);
    }
    
    [_parentContext interrupt];
}

@end
