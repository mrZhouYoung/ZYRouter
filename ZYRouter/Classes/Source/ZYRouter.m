//
//  ZYRouter.m
//  Pods
//
//  Created by Young on 2024/12/13.
//

#import "ZYRouter.h"
#import "BlockTask.h"

NSString *const RoutesRedirectURLKey = @"redirect";
NSString *const RoutesInterceptorKey = @"interceptors";
NSString *const RoutesInterceptorClassKey = @"interceptorClass";
NSString *const RoutesInterceptorOptionsKey = @"interceptorOptions";
NSString *const RoutesTaskClassKey = @"taskClass";
NSString *const RoutesTaskOptionsKey = @"taskOptions";
NSString *const RoutesControllerClassKey = @"controllerClass";
NSString *const RoutesControllerPresentKey = @"present";
NSString *const RoutesControllerWrapClassKey = @"wrap";
NSString *const RoutesControllerPushFromKey = @"from";
NSString *const RoutesControllerAnimatedKey = @"animated";
NSString *const RoutesBlockKey = @"block";

NSString *const SubRoutesKey = @"subRoutes";

@interface ZYRouter ()

@property (nonatomic, assign) BOOL treatHostAsPathComponent;

@property (nonatomic, copy) void (^defaultCompletionHandler)(RouteResponse *);

@property (nonatomic, strong) NSMutableDictionary *routes;
@property (nonatomic, strong) NSMutableDictionary *blockRoutes;
@property (nonatomic, strong) NSMutableArray<RouteContext *> *contexts;

@end

@implementation ZYRouter

static ZYRouter *shared;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [self new];
    });
    return shared;
}

+ (BOOL)canRoute:(NSString *)URL {
    RouteMatcher *matcher = [[RouteMatcher alloc] initWithRoutes:[[ZYRouter shared].routes copy] treatHostAsPathComponent:[ZYRouter shared].treatHostAsPathComponent];
    return [matcher patternForURL:URL params:nil];
}

+ (BOOL)canRoute:(NSString *)URL params:(NSDictionary *)params {
    RouteMatcher *matcher = [[RouteMatcher alloc] initWithRoutes:[[ZYRouter shared].routes copy] treatHostAsPathComponent:[ZYRouter shared].treatHostAsPathComponent];
    return [matcher patternForURL:URL params:params];
}

+ (RouteContextMaker *(^)(NSString *))URL {
    return ^RouteContextMaker *(NSString *URL) {
        RouteMatcher *matcher = [[RouteMatcher alloc] initWithRoutes:[[ZYRouter shared].routes copy] treatHostAsPathComponent:[ZYRouter shared].treatHostAsPathComponent];
        
        return [[RouteContextMaker alloc] initWithURL:URL matcher:matcher].defaultCompletionHandler([ZYRouter shared].defaultCompletionHandler);
    };
}

+ (void)mapBlock:(void (^)(NSDictionary *))block
           toURL:(NSString *)URL {
    if (!block) {
        return;
    }
    [[ZYRouter shared].blockRoutes setObject:[block copy] forKey:URL];
    [self mapTaskClass:[BlockTask class] taskOptions:@{RoutesBlockKey: [block copy]} toURL:URL];
}

+ (void)mapTaskClass:(Class)taskClass
         taskOptions:(NSDictionary *)options
               toURL:(NSString *)URL {
    if (options) {
        NSAssert([options isKindOfClass:[NSDictionary class]], @"options should be NSDictionary instance");
    }
    
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:URL];
    subRoutes[RoutesTaskClassKey] = NSStringFromClass(taskClass);
    subRoutes[RoutesTaskOptionsKey] = options ?: @{};
}

+ (void)mapInterceptors:(NSArray <Class>*)classesArray
     interceptorOptions:(NSArray <NSDictionary *>*)optionsArray
                  toURL:(NSString *)URL {
    NSAssert(classesArray.count == optionsArray.count, @"options count should match classes count");
    NSMutableArray *interceptors = [NSMutableArray array];
    for (NSUInteger index = 0; index < classesArray.count; index++) {
        Class c = [classesArray objectAtIndex:index];
        NSDictionary *options = [optionsArray objectAtIndex:index];
        
        NSAssert([options isKindOfClass:[NSDictionary class]], @"options should be NSDictionary instance");
        
        NSMutableDictionary *interceptor = [NSMutableDictionary dictionary];
        interceptor[RoutesInterceptorClassKey] = NSStringFromClass(c);
        interceptor[RoutesInterceptorOptionsKey] = options;
        
        [interceptors addObject:interceptor];
    }
    
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:URL];
    subRoutes[RoutesInterceptorKey] = interceptors;
}

+ (void)mapRedirectURL:(NSString *)redirect
                 toURL:(NSString *)URL {
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:URL];
    subRoutes[RoutesRedirectURLKey] = redirect;
}

+ (NSMutableDictionary *)subRoutesToRoute:(NSString *)route {
    NSMutableDictionary *subRoutes = [ZYRouter shared].routes;
    
    NSArray *components = [[[route stringByReplacingOccurrencesOfString:@"/" withString:@" /"] substringFromIndex:1] componentsSeparatedByString:@" "];
    
    for (NSUInteger index = 0; index < components.count; index++) {
        NSString *component = [components objectAtIndex:index];
        
        if (!subRoutes[component]) {
            subRoutes[component] = [NSMutableDictionary dictionary];
        }
        subRoutes = subRoutes[component];
    }
    
    return subRoutes;
}

+ (void)setConfigurationFilePath:(NSString *)path {
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    if (!data) {
        return;
    }
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
    
    if (error || !json || ![json isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSMutableDictionary *routes = [NSMutableDictionary dictionaryWithDictionary:json];
    if (routes) {
        [ZYRouter shared].routes = routes;
        NSDictionary *blockRoutes = [[ZYRouter shared].blockRoutes copy];
        for (NSString *key in blockRoutes) {
            [ZYRouter mapBlock:blockRoutes[key] toURL:key];
        }
    }
}

+ (void)setTreatHostAsPathComponent:(BOOL)treatHostAsPathComponent {
    [ZYRouter shared].treatHostAsPathComponent = treatHostAsPathComponent;
}

+ (void)setDefaultCompletionHandler:(void (^)(RouteResponse *))completionHandler {
    [ZYRouter shared].defaultCompletionHandler = [completionHandler copy];
}

+ (void)addRouteContext:(RouteContext *)context {
    [[ZYRouter shared].contexts addObject:context];
}

+ (void)removeRouteContext:(RouteContext *)context {
    [[ZYRouter shared].contexts removeObject:context];
}

#pragma mark - getter
- (NSMutableDictionary *)routes {
    if (!_routes) {
        _routes = [NSMutableDictionary dictionary];
    }
    return _routes;
}

- (NSMutableDictionary *)blockRoutes {
    if (!_blockRoutes) {
        _blockRoutes = [NSMutableDictionary dictionary];
    }
    return _blockRoutes;
}

- (NSMutableArray *)contexts {
    if (!_contexts) {
        _contexts = [NSMutableArray array];
    }
    return _contexts;
}

@end
