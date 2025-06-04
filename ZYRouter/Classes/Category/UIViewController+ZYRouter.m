//
//  UIViewController+ZYRouter.m
//  ZYRouter
//
//  Created by Young on 2024/12/14.
//

#import "UIViewController+ZYRouter.h"
#import <objc/runtime.h>

@implementation UIViewController (ZYRouter)

- (void)setZy_routeURL:(NSString *)zy_routeURL {
    objc_setAssociatedObject(self, @"zy_routeURL", zy_routeURL, OBJC_ASSOCIATION_COPY);
}

- (NSString *)zy_routeURL {
    return objc_getAssociatedObject(self, @"zy_routeURL");
}

- (void)setZy_routeParams:(NSDictionary *)zy_routeParams {
    objc_setAssociatedObject(self, @"zy_routeParams", zy_routeParams, OBJC_ASSOCIATION_RETAIN);
}

- (NSDictionary *)zy_routeParams {
    return objc_getAssociatedObject(self, @"zy_routeParams");
}

- (void)setZy_routeRequest:(RouteRequest *)zy_routeRequest {
    objc_setAssociatedObject(self, @"zy_routeRequest", zy_routeRequest, OBJC_ASSOCIATION_RETAIN);
}

- (RouteRequest *)zy_routeRequest {
    return objc_getAssociatedObject(self, @"zy_routeRequest");
}

- (void)setZy_routeInterceptor:(RouteInterceptor *)zy_routeInterceptor {
    objc_setAssociatedObject(self, @"zy_routeInterceptor", zy_routeInterceptor, OBJC_ASSOCIATION_RETAIN);
}

- (RouteInterceptor *)zy_routeInterceptor {
    return objc_getAssociatedObject(self, @"zy_routeInterceptor");
}

+ (UIViewController *)zy_topMostViewController {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.rootViewController) {
            return [UIViewController zy_topMostViewControllerOf:window.rootViewController];
        }
    }
    
    return nil;
}

+ (UIViewController *)zy_topMostViewControllerOf:(UIViewController *)controller {
    if (controller.presentedViewController) {
        return [self zy_topMostViewControllerOf:controller.presentedViewController];
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *)controller).topViewController;
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self zy_topMostViewControllerOf:((UITabBarController *)controller).selectedViewController];
    } else {
        for (UIView *view in controller.view.subviews) {
            if ([view.nextResponder isKindOfClass:[UIViewController class]]) {
                return (UIViewController *)view.nextResponder;
            }
        }
        return controller;
    }
}

@end
