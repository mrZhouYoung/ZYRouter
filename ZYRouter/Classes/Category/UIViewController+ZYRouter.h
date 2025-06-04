//
//  UIViewController+ZYRouter.h
//  ZYRouter
//
//  Created by Young on 2024/12/14.
//

#import <UIKit/UIKit.h>

@class RouteRequest, RouteInterceptor;

@interface UIViewController (ZYRouter)


/**
 当前页面URL
 */
@property (nonatomic, copy) NSString *zy_routeURL;


/**
 路由参数
 */
@property (nonatomic, strong) NSDictionary *zy_routeParams;


/**
 路由请求
 */
@property (nonatomic, strong) RouteRequest *zy_routeRequest;


/**
 拦截器
 */
@property (nonatomic, strong) RouteInterceptor *zy_routeInterceptor;


/**
 查找当前app中的顶层viewController
 */
+ (UIViewController *)zy_topMostViewController;


/**
 查找当前viewController中的顶层viewController
 */
+ (UIViewController *)zy_topMostViewControllerOf:(UIViewController *)controller;

@end
