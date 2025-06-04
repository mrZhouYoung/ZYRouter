//
//  RouteMatcher.m
//  ZYRouter
//
//  Created by Young on 2025/1/12.
//

#import "ZYRouter.h"

@implementation RouteMatcher {
    NSDictionary *_routes;
    BOOL _treatHostAsPathComponent;
}

- (instancetype)initWithRoutes:(NSDictionary *)routes treatHostAsPathComponent:(BOOL)treatHostAsPathComponent {
    if (self = [super init]) {
        _routes = routes;
        _treatHostAsPathComponent = treatHostAsPathComponent;
    }
    return self;
}

/**
 匹配路由模板
 */
- (NSString *)patternForURL:(NSString *)URL params:(NSDictionary *)params {
    NSArray *components = [self patternComponentsForURL:URL params:params];
    
    if (components.count) {
        NSLog(@"%s \n pattern:%@ \n url:%@ \n params:%@", __func__, [components componentsJoinedByString:@""], URL, params);
        return [components componentsJoinedByString:@""];
    } else {
        return nil;
    }
}

- (NSArray *)patternComponentsForURL:(NSString *)URL params:(NSDictionary *)params {
    NSArray *routeComponents = [self routeComponentsInURL:URL];
    
    NSMutableDictionary *paramsInQuery = [[self paramsInQuery:[[URL componentsSeparatedByString:@"?"] lastObject]] mutableCopy];
    [paramsInQuery addEntriesFromDictionary:params ?: @{}];
    params = [paramsInQuery copy];
    
    NSMutableArray *patternComponents = [NSMutableArray array];
    
    NSDictionary *routes = _routes;
    for (NSString *component in routeComponents) {
        NSString *patternComponent = [self patternComponentForRouteComponent:component params:params inRoutes:routes];
        if (patternComponent) {
            [patternComponents addObject:patternComponent];
            routes = [self subRoutesForPatternComponent:patternComponent inRoutes:routes];
        } else {
            return nil;
        }
    }
    
    if (patternComponents.count > 0) {
        return patternComponents;
    } else {
        return nil;
    }
}

- (NSString *)redirectURLForPatternURL:(NSString *)patternURL {
    NSArray *patternComponents = [self patternComponentsInPatternURL:patternURL];
    NSDictionary *routes = _routes;
    for (NSUInteger i = 0; i < patternComponents.count; i++) {
        routes = [self subRoutesForPatternComponent:patternComponents[i] inRoutes:routes];
    }
    
    return [routes objectForKey:RoutesRedirectURLKey];
}

- (NSArray<RouteInterceptor *> *)interceptorsForPatternURL:(NSString *)patternURL error:(NSError **)error {
    NSMutableArray *interceptors = [NSMutableArray array];
    
    NSArray *patternComponents = [self patternComponentsInPatternURL:patternURL];
    NSDictionary *routes = _routes;
    for (NSUInteger i = 0; i < patternComponents.count; i++) {
        routes = [self subRoutesForPatternComponent:patternComponents[i] inRoutes:routes];
        NSArray *tmp = [self interceptorsInSubRoutes:routes error:error];
        if (*error) {
            return nil;
        }
        [interceptors addObjectsFromArray:tmp];
    }
    return [interceptors copy];
}

- (NSArray<RouteInterceptor *> *)interceptorsInSubRoutes:(NSDictionary *)subRoutes error:(NSError **)error {
    NSMutableArray *array = [NSMutableArray array];
    
    id interceptors = [subRoutes objectForKey:RoutesInterceptorKey];
    if ([interceptors isKindOfClass:[NSString class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:interceptors forKey:RoutesInterceptorClassKey];
        [array addObject:dict];
    } else if ([interceptors isKindOfClass:[NSArray class]]) {
        for (id obj in interceptors) {
            if ([obj isKindOfClass:[NSString class]]) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:obj forKey:RoutesInterceptorClassKey];
                [array addObject:dict];
            } else if ([obj isKindOfClass:[NSDictionary class]]) {
                [array addObject:obj];
            }
        }
    }
    
    NSMutableArray *interceptorObjects = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NSString *class = [dict objectForKey:RoutesInterceptorClassKey];
        if (!class) {
            // error
            *error = [NSError errorWithDomain:@"ZYRouterErrorDomain" code:ResponseCodeInterceptorInstantiateError userInfo:@{@"message": [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__]}];
            return nil;
        }
        Class c = NSClassFromString(class);
        if (!c) {
            // error
            *error = [NSError errorWithDomain:@"ZYRouterErrorDomain" code:ResponseCodeInterceptorInstantiateError userInfo:@{@"message": [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__]}];
            return nil;
        }
        RouteInterceptor *interceptor = [[c alloc] init];
        if (!interceptor) {
            // error
            *error = [NSError errorWithDomain:@"ZYRouterErrorDomain" code:ResponseCodeInterceptorInstantiateError userInfo:@{@"message": [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__]}];
            return nil;
        }
        if (![interceptor isKindOfClass:[RouteInterceptor class]]) {
            // error
            *error = [NSError errorWithDomain:@"ZYRouterErrorDomain" code:ResponseCodeInterceptorInstantiateError userInfo:@{@"message": [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__]}];
            return nil;
        }
        interceptor.options = [dict objectForKey:RoutesInterceptorOptionsKey];
        [interceptorObjects addObject:interceptor];
    }
    
    return [interceptorObjects copy];
}

- (id<RouteTaskProtocol>)routeTaskForPatternURL:(NSString *)patternURL error:(NSError **)error {
    NSArray *patternComponents = [self patternComponentsInPatternURL:patternURL];
    NSDictionary *routes = _routes;
    NSString *classString = [_routes objectForKey:RoutesTaskClassKey];
    NSDictionary *taskOptions;
    for (NSUInteger i = 0; i < patternComponents.count; i++) {
        routes = [self subRoutesForPatternComponent:patternComponents[i] inRoutes:routes];
        NSString *tmp = [routes objectForKey:RoutesTaskClassKey];
        if (tmp) {
            classString = tmp;
        }
        taskOptions = [routes objectForKey:RoutesTaskOptionsKey];
    }
    
    if (!classString) {
        // error
        *error = [NSError errorWithDomain:@"ZYRouterErrorDomain" code:ResponseCodeTaskInstantiateError userInfo:@{@"message": [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__]}];
        return nil;
    }
    Class c = NSClassFromString(classString);
    if (!c) {
        // error
        *error = [NSError errorWithDomain:@"ZYRouterErrorDomain" code:ResponseCodeTaskInstantiateError userInfo:@{@"message": [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__]}];
        return nil;
    }
    id<RouteTaskProtocol> task = [[c alloc] init];
    if (!task) {
        // error
        *error = [NSError errorWithDomain:@"ZYRouterErrorDomain" code:ResponseCodeTaskInstantiateError userInfo:@{@"message": [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__]}];
        return nil;
    }
    if (!taskOptions) {
        // error
        *error = [NSError errorWithDomain:@"ZYRouterErrorDomain" code:ResponseCodeTaskInstantiateError userInfo:@{@"message": [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__]}];
        return nil;
    }
    if ([taskOptions isKindOfClass:[NSDictionary class]]) {
        task.options = taskOptions;
    } else if ([taskOptions isKindOfClass:[NSString class]]) {
        task.options = [NSDictionary dictionaryWithObjectsAndKeys:taskOptions, RoutesControllerClassKey, nil];
    } else {
        // error
        *error = [NSError errorWithDomain:@"ZYRouterErrorDomain" code:ResponseCodeTaskInstantiateError userInfo:@{@"message": [NSString stringWithFormat:@"%s %d", __FILE__, __LINE__]}];
        return nil;
    }
    
    return task;
}

/**
 在routes层及其subRoutes层内为component寻找模板component
 */
- (NSString *)patternComponentForRouteComponent:(NSString *)component params:(NSDictionary *)params inRoutes:(NSDictionary *)routes {
    NSString *pathComponent = component;
    
    // 先找当前层
    NSString *wildcardKey;
    NSString *defaultKey;
    NSArray *keys = routes.allKeys;
    for (NSString *key in keys) {
        if ([key containsString:@"?"]) {
            if (![key hasPrefix:[pathComponent stringByAppendingString:@"?"]] && ![key hasPrefix:@"/:"]) {
                continue;
            }
            NSDictionary *patternParams = [self paramsInQuery:[[key componentsSeparatedByString:@"?"] lastObject]];
            if (params) {
                NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:params];
                [tmp addEntriesFromDictionary:patternParams];
                if ([tmp isEqual:params]) {
                    if ([key hasPrefix:@"/:"]) {
                        // 记录通配符
                        wildcardKey = key;
                        continue;
                    }
                    // 精确匹配到参数
                    return key;
                }
            }
        } else {
            if ([key isEqualToString:pathComponent]) {
                defaultKey = key;
            } else if ([key hasPrefix:@"/:"]) {
                wildcardKey = key;
            }
        }
    }
    if (defaultKey) {
        return defaultKey;
    }
    if (wildcardKey) {
        return wildcardKey;
    }
    
    // 没找到，找subRoutes层
    NSDictionary *subRoutes = [routes objectForKey:SubRoutesKey];
    if (subRoutes) {
        return [self patternComponentForRouteComponent:component params:params inRoutes:subRoutes];
    } else {
        return nil;
    }
}

/**
 在routes层及其subRoutes层内为component定位层
 */
- (NSDictionary *)subRoutesForPatternComponent:(NSString *)component inRoutes:(NSDictionary *)routes {
    NSDictionary *subRoutes = [routes objectForKey:component];
    if (!subRoutes) {
        subRoutes = [[routes objectForKey:SubRoutesKey] objectForKey:component];
    }
    
    return subRoutes;
}

- (NSDictionary *)paramsInPatternURL:(NSString *)patternURL withURL:(NSString *)URL {
    NSArray *patternComponents = [self patternComponentsInPatternURL:patternURL];
    NSArray *routeComponents = [self routeComponentsInURL:URL];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    for (int i = 0; i < patternComponents.count; i++) {
        NSString *key = [[patternComponents[i] componentsSeparatedByString:@"?"] firstObject];
        NSString *value = routeComponents[i];
        if ([key hasPrefix:@"/:"] && key.length > 2 && value.length > 1) {
            [params setValue:[value substringFromIndex:1] forKey:[key substringFromIndex:2]];
        }
    }
    
    if ([URL containsString:@"?"]) {
        NSDictionary *paramsInQuery = [self paramsInQuery:[[URL componentsSeparatedByString:@"?"] lastObject]];
        [params addEntriesFromDictionary:paramsInQuery];
    }
    
    return [params copy];
}

- (NSDictionary *)paramsInQuery:(NSString *)query {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSArray *keyValues = [query componentsSeparatedByString:@"&"];
    for (NSString *keyValue in keyValues) {
        NSArray *keyAndValue = [keyValue componentsSeparatedByString:@"="];
        if (keyAndValue.count == 2) {
            [params setValue:[[keyAndValue lastObject] stringByRemovingPercentEncoding] forKey:[keyAndValue firstObject]];
        }
    }
    
    return [params copy];
}

- (NSArray<NSString *> *)routeComponentsInURL:(NSString *)URL {
    URL = [self stringByFilterAppURLSchemes:URL treatHostAsPathComponent:_treatHostAsPathComponent];
    
    URL = [[URL componentsSeparatedByString:@"?"] firstObject];
    if ([URL hasPrefix:@"/"]) {
        URL = [URL stringByReplacingOccurrencesOfString:@"/" withString:@" /"];
        URL = [URL substringFromIndex:1];
        return [URL componentsSeparatedByString:@" "];
    } else {
        return nil;
    }
}

- (NSArray *)patternComponentsInPatternURL:(NSString *)patternURL {
    NSArray *patternComponents = [[[patternURL stringByReplacingOccurrencesOfString:@"/" withString:@" /"] substringFromIndex:1] componentsSeparatedByString:@" "];
    
    return patternComponents;
}

- (NSString *)stringByFilterAppURLSchemes:(NSString *)URL treatHostAsPathComponent:(BOOL)treatHostAsPathComponent {    
    for (NSString *appURLScheme in [self appURLSchemes]) {
        if ([URL hasPrefix:[NSString stringWithFormat:@"%@:", appURLScheme]]) {
            if (treatHostAsPathComponent) {
                return [URL substringFromIndex:appURLScheme.length + 2];
            } else {
                NSURL *url = [NSURL URLWithString:URL];
                NSString *path = [url path];
                NSString *query = [url query];
                
                if (query.length) {
                    path = [path stringByAppendingFormat:@"?%@", query];
                }
                
                return path;
            }
        }
    }
    
    return URL;
}

- (NSArray *)appURLSchemes {
    static NSArray *schemes;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *appURLSchemes = [NSMutableArray array];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        for (NSDictionary *dic in infoDictionary[@"CFBundleURLTypes"]) {
            NSArray *schemes = dic[@"CFBundleURLSchemes"];
            for (NSString *appURLScheme in schemes) {
                [appURLSchemes addObject:appURLScheme];
            }
        }
        
        schemes = [appURLSchemes copy];
    });
    
    return schemes;
}

@end
