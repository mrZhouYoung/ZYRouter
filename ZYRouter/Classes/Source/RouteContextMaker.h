//
//  RouteContextMaker.h
//  ZYRouter
//
//  Created by Young on 2024/12/21.
//

#import <UIKit/UIKit.h>

@class RouteContext, RouteResponse;

@interface RouteContextMaker : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSString *)URL matcher:(RouteMatcher *)matcher;

- (RouteContextMaker *(^)(NSString *))redirectFrom;
- (RouteContextMaker *(^)(NSDictionary *))params;

- (RouteContextMaker *(^)(void))present;
- (RouteContextMaker *(^)(Class))wrapIn;
- (RouteContextMaker *(^)(void))push;
- (RouteContextMaker *(^)(UIViewController *))pushFrom;

- (RouteContextMaker *(^)(void))removeAllInterceptors;
- (RouteContextMaker *(^)(NSArray<Class> *))removeInterceptors;
- (RouteContextMaker *(^)(NSArray<Class> *))appendInterceptors;
- (RouteContextMaker *(^)(NSArray<NSDictionary *> *))appendInterceptorOptions;
- (RouteContextMaker *(^)(NSArray<NSNumber *> *))appendInterceptorIndexes;

- (RouteContextMaker *(^)(__unsafe_unretained Class))taskClass;
- (RouteContextMaker *(^)(NSDictionary *))taskOptions;
- (RouteContextMaker *(^)(void (^)(RouteResponse *)))defaultCompletionHandler;
- (RouteContextMaker *(^)(void (^)(RouteResponse *)))completionHandler;

- (RouteContextMaker *(^)(RouteContext *))parentContext;

- (BOOL (^)(void))route;

@end
