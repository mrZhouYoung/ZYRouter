//
//  RouteMatcher.h
//  ZYRouter
//
//  Created by Young on 2025/1/12.
//

#import <Foundation/Foundation.h>

@class RouteInterceptor;
@protocol RouteTaskProtocol;

@interface RouteMatcher : NSObject

- (instancetype)initWithRoutes:(NSDictionary *)routes treatHostAsPathComponent:(BOOL)treatHostAsPathComponent;

- (NSString *)patternForURL:(NSString *)URL params:(NSDictionary *)params;

- (NSString *)redirectURLForPatternURL:(NSString *)patternURL;

- (NSDictionary *)paramsInPatternURL:(NSString *)patternURL withURL:(NSString *)URL;

- (NSArray<RouteInterceptor *> *)interceptorsForPatternURL:(NSString *)patternURL error:(NSError **)error;

- (id<RouteTaskProtocol>)routeTaskForPatternURL:(NSString *)patternURL error:(NSError **)error;

@end
