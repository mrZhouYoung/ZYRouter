//
//  ZYRouter.h
//  Pods
//
//  Created by Young on 2024/12/13.
//

#import "RouteMatcher.h"
#import "RouteContextMaker.h"
#import "RouteRequest.h"
#import "RouteResponse.h"
#import "RouteInterceptor.h"
#import "RouteContext.h"
#import "RouteTaskProtocol.h"
#import "UIViewController+ZYRouter.h"

/*
 配置文件：redicrect、interceptors、taskClass、taskOptions、subRoutes
 */

/*
 redirect功能
 链式写法
 open、push、present api 删除
 maker类
 配置VO，保持数据结构一致
 */


extern NSString *const RoutesRedirectURLKey;
extern NSString *const RoutesInterceptorKey;
extern NSString *const RoutesInterceptorClassKey;
extern NSString *const RoutesInterceptorOptionsKey;
extern NSString *const RoutesTaskClassKey;
extern NSString *const RoutesTaskOptionsKey;
extern NSString *const RoutesControllerClassKey;
extern NSString *const RoutesControllerPresentKey;
extern NSString *const RoutesControllerWrapClassKey;
extern NSString *const RoutesControllerPushFromKey;
extern NSString *const RoutesControllerAnimatedKey;
extern NSString *const RoutesBlockKey;

extern NSString *const SubRoutesKey;

@interface ZYRouter : NSObject

#pragma mark - route
+ (BOOL)canRoute:(NSString *)URL;
+ (BOOL)canRoute:(NSString *)URL params:(NSDictionary *)params;
+ (RouteContextMaker *(^)(NSString *))URL;

#pragma mark - map
+ (void)mapBlock:(void (^)(NSDictionary *))block
           toURL:(NSString *)URL;

+ (void)mapTaskClass:(Class)taskClass
         taskOptions:(NSDictionary *)options
               toURL:(NSString *)URL;

+ (void)mapInterceptors:(NSArray <Class>*)classesArray
     interceptorOptions:(NSArray <NSDictionary *>*)optionsArray
                  toURL:(NSString *)URL;

+ (void)mapRedirectURL:(NSString *)redirect
                 toURL:(NSString *)URL;

#pragma mark - other
+ (void)setConfigurationFilePath:(NSString *)path;
+ (void)setTreatHostAsPathComponent:(BOOL)treatHostAsPathComponent;
+ (void)setDefaultCompletionHandler:(void (^)(RouteResponse *))completionHandler;

+ (void)addRouteContext:(RouteContext *)context;
+ (void)removeRouteContext:(RouteContext *)context;

@end
