//
//  InterceptorCViewController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/15.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "InterceptorCViewController.h"
#import "RouteInterceptor+last.h"
#import "User.h"
#import "ZYRouter.h"

@interface InterceptorCViewController ()

@end

@implementation InterceptorCViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"拦截器C";
    
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = close;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitle:@"下一步" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    self.view = btn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)next {
    ZYRouter.URL(@"/interceptorC2").push().route();
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (self.zy_routeInterceptor) {
            [self.zy_routeInterceptor.context interceptor:self.zy_routeInterceptor finishedWithState:RouteInterceptionStateUserCancel];
        }
    }];
}

@end
