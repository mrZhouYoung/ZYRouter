//
//  InterceptorAViewController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "InterceptorAViewController.h"
#import "RouteInterceptor+last.h"
#import "User.h"
#import "ZYRouter.h"

@interface InterceptorAViewController ()

@end

@implementation InterceptorAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"拦截器A";
    
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = close;
    
    UIBarButtonItem *verify = [[UIBarButtonItem alloc] initWithTitle:@"验证" style:UIBarButtonItemStyleDone target:self action:@selector(verify)];
    self.navigationItem.rightBarButtonItem = verify;
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"切换拦截器A状态至" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismiss];
    }];
    UIAlertAction *a = [UIAlertAction actionWithTitle:@"失败" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [User currentUser].a = @0;
        [self next];
    }];
    UIAlertAction *b = [UIAlertAction actionWithTitle:@"成功" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [User currentUser].a = @1;
        [self next];
    }];
    UIAlertAction *c = [UIAlertAction actionWithTitle:@"pending" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [User currentUser].a = @-1;
        [self next];
    }];
    [alert addAction:cancel];
    [alert addAction:b];
    [alert addAction:a];
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
