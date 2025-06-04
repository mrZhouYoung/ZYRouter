//
//  InterceptorC2ViewController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "InterceptorC2ViewController.h"
#import "RouteInterceptor+last.h"
#import "User.h"
#import "ZYRouter.h"

@interface InterceptorC2ViewController ()

@end

@implementation InterceptorC2ViewController

- (instancetype)init {
    if (self = [super init]) {
        self.navigationItem.title = @"拦截器C";
        
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

- (void)verify {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"切换拦截器C状态至" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *a = [UIAlertAction actionWithTitle:@"成功" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [User currentUser].c = @1;
        [self next];
    }];
    UIAlertAction *b = [UIAlertAction actionWithTitle:@"失败" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [User currentUser].c = @0;
        [self next];
    }];
    [alert addAction:cancel];
    [alert addAction:a];
    [alert addAction:b];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)next {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    item.enabled = NO;
    self.navigationItem.rightBarButtonItem = item;
    
    UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers indexOfObject:self]-1];
    RouteInterceptor *interceptor = vc.zy_routeInterceptor;
    
    if (interceptor) {
        if ([interceptor isLast]) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                [interceptor verified];
            }];
        } else {
            [interceptor verified];
        }
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
