//
//  TabBarControllerTask.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "TabBarControllerTask.h"
#import "TabBarController.h"
#import "ZYRouter.h"
#import "UIViewController+ZYRouter.h"
#import <objc/runtime.h>

@implementation TabBarControllerTask

SYNTHESIZE_CONTEXT
SYNTHESIZE_PARAMS
SYNTHESIZE_OPTIONS
SYNTHESIZE_COMPLETIONHANDLER

- (void)excute {
    NSArray *navs = [TabBarController shared].viewControllers;
    
    NSNumber *index = nil;
    
    for (int i = 0; i < navs.count; i++) {
        UINavigationController *nav = navs[i];
        UIViewController *vc = nav.viewControllers[0];
        if ([[self.options objectForKey:RoutesControllerClassKey] isEqualToString:NSStringFromClass([vc class])]) {
            index = @(i);
            
            NSMutableDictionary *params = [self.params mutableCopy];
            if (self.options) {
                [params addEntriesFromDictionary:self.options];
            }
            
            vc.zy_routeURL = self.context.request.URL;
            vc.zy_routeParams = params;
            vc.zy_routeRequest = self.context.request;
            vc.zy_routeInterceptor = self.context.parentContext.currentInterceptor;
            
            break;
        }
    }
    
    if (index) {
        [TabBarController shared].selectedIndex = [index unsignedIntegerValue];
        for (UINavigationController *nav in [TabBarController shared].viewControllers) {
            [nav popToRootViewControllerAnimated:NO];
        }
        return;
    }
    
    [self excutionErrorWithMessage:[NSString stringWithFormat:@"controller class not found for URL: %@", self.context.request.URL]];
}

- (void)excutionErrorWithMessage:(NSString *)message {
    RouteResponse *response = [[RouteResponse alloc] initWithCode:ResponseCodeTaskExcutionError message:message];
    RouteContext *context = self.context;
    if (context.task.completionHandler) {
        context.task.completionHandler(response);
    }
    while (context) {
        RouteContext *parent = context.parentContext;
        [context removeFromParentContext];
        context = parent;
    }
}

@end
