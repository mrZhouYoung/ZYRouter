//
//  LoginViewController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "LoginViewController.h"
#import "RouteInterceptor+last.h"
#import "User.h"
#import "ZYRouter.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (instancetype)init {
    if (self = [super init]) {
        self.navigationItem.title = @"登录";
        
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
        self.navigationItem.leftBarButtonItem = close;
        
        UIBarButtonItem *login = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStyleDone target:self action:@selector(login)];
        self.navigationItem.rightBarButtonItem = login;
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

- (void)login {
    [User loginWithUid:@"8888" token:@"1234"];

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
