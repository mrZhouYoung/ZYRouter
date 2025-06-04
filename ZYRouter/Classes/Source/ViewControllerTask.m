//
//  ViewControllerTask.m
//  ZYRouter
//
//  Created by Young on 2024/12/28.
//

#import "ViewControllerTask.h"
#import "ZYRouter.h"
#import "UIViewController+ZYRouter.h"
#import <objc/runtime.h>

@implementation ViewControllerTask

SYNTHESIZE_CONTEXT
SYNTHESIZE_PARAMS
SYNTHESIZE_OPTIONS
SYNTHESIZE_COMPLETIONHANDLER

- (void)excute {
    NSString *c;
    if ([self.options isKindOfClass:[NSString class]]) {
        c = (NSString *)self.options;
    } else if ([self.options isKindOfClass:[NSDictionary class]]) {
        c = self.options[RoutesControllerClassKey];
    } else {
        [self excutionErrorWithMessage:[NSString stringWithFormat:@"task options error for URL: %@", self.context.request.URL]];
        return;
    }
    if (!c) {
        [self excutionErrorWithMessage:[NSString stringWithFormat:@"controller class not found for URL: %@", self.context.request.URL]];
        return;
    }
    UIViewController *viewController = [NSClassFromString(c) new];
    if (!viewController) {
        [self excutionErrorWithMessage:[NSString stringWithFormat:@"cannot instantiate controller for URL: %@", self.context.request.URL]];
        return;
    }
    NSMutableDictionary *params = [self.params mutableCopy];
    if (self.options) {
        [params addEntriesFromDictionary:self.options];
    }
    
    viewController.zy_routeURL = self.context.request.URL;
    viewController.zy_routeParams = params;
    viewController.zy_routeRequest = self.context.request;
    viewController.zy_routeInterceptor = self.context.parentContext.currentInterceptor;
    
    BOOL animated = YES;
    if (self.options[RoutesControllerAnimatedKey] && [self.options[RoutesControllerAnimatedKey] intValue] == 0) {
        animated = NO;
    }
    
    BOOL present = [self.options[RoutesControllerPresentKey] boolValue];
    if (present) {
        c = self.options[RoutesControllerWrapClassKey];
        if (c) {
            Class navigationClass = NSClassFromString(c);
            // 错误处理
            UINavigationController *navigationController = [[navigationClass alloc]  initWithRootViewController:viewController];
            viewController = navigationController;
        }
        [[UIViewController zy_topMostViewController] presentViewController:viewController animated:animated completion:^{
            [self excutionSuccedd];
        }];
    } else {
        UINavigationController *navigationController;
        UIViewController *from = self.options[RoutesControllerPushFromKey];
        if (!from) {
            from = [UIViewController zy_topMostViewController];
        }
        if ([from isKindOfClass:[UINavigationController class]]) {
            navigationController = (UINavigationController *)from;
        } else {
            navigationController = from.navigationController;
        }
        [navigationController pushViewController:viewController animated:animated];
        [self excutionSuccedd];
    }
}

- (void)excutionSuccedd {
    RouteResponse *response = [[RouteResponse alloc] initWithCode:ResponseCodeOK message:[NSString stringWithFormat:@"route URL OK: %@", self.context.request.URL]];
    RouteContext *context = self.context;
    if (context.task.completionHandler) {
        context.task.completionHandler(response);
    }
    [context removeFromParentContext];
}

- (void)excutionErrorWithMessage:(NSString *)message {
    RouteResponse *response = [[RouteResponse alloc] initWithCode:ResponseCodeTaskExcutionError message:message];
    RouteContext *context = self.context;
    if (context.task.completionHandler) {
        context.task.completionHandler(response);
    }
    [context interrupt];
}

@end
