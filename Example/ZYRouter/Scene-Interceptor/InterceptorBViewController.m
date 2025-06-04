//
//  InterceptorBViewController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "InterceptorBViewController.h"
#import "RouteInterceptor+last.h"
#import "User.h"
#import "ZYRouter.h"

@interface InterceptorBViewController ()

@end

@implementation InterceptorBViewController

- (instancetype)init {
    if (self = [super init]) {
        self.navigationItem.title = @"拦截器B";
        
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
        self.navigationItem.leftBarButtonItem = close;
        
        UIBarButtonItem *verify = [[UIBarButtonItem alloc] initWithTitle:@"验证" style:UIBarButtonItemStyleDone target:self action:@selector(verify)];
        self.navigationItem.rightBarButtonItem = verify;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (self.zy_routeInterceptor) {
            [self.zy_routeInterceptor.context interceptor:self.zy_routeInterceptor finishedWithState:RouteInterceptionStateUserCancel];
        }
    }];
}

- (void)verify {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"切换拦截器B状态至" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismiss];
    }];
    UIAlertAction *a = [UIAlertAction actionWithTitle:@"成功" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [User currentUser].b = @(1);
        [self next];
    }];
    UIAlertAction *b = [UIAlertAction actionWithTitle:@"失败" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [User currentUser].b = @(0);
        [self next];
    }];
    UIAlertAction *c = [UIAlertAction actionWithTitle:@"审核中" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [User currentUser].b = @(-1);
        [self next];
    }];
    [alert addAction:cancel];
    [alert addAction:a];
    [alert addAction:b];
    [alert addAction:c];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)next {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    item.enabled = NO;
    self.navigationItem.rightBarButtonItem = item;
    
    if (self.zy_routeInterceptor) {
        if ([self.zy_routeInterceptor isLast]) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [self.zy_routeInterceptor verified];
            }];
        } else {
            [self.zy_routeInterceptor verified];
        }
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
