//
//  InterceptorNavigationController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/15.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "InterceptorNavigationController.h"

@interface InterceptorNavigationController ()

@end

@implementation InterceptorNavigationController

static InterceptorNavigationController *nav;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nav = [[self alloc] init];
    });
    return nav;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    
    if (!self.presentingViewController) {
        self.viewControllers = @[viewController];
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:self animated:YES completion:nil];
    }
}

@end
