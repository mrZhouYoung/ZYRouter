//
//  TabBarController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "TabBarController.h"
#import "NavigationController.h"
#import "HomeViewController.h"
#import "OrdersViewController.h"
#import "DiscoveryViewController.h"
#import "MineViewController.h"
#import "ZYRouter.h"

@interface TabBarController ()

@end

@implementation TabBarController {
    NSArray *_cls;
    NSArray *_URLs;
    NSArray *_tabBarItemTitles;
}

static TabBarController *instance;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _cls = @[@"HomeViewController", @"NearbyViewController", @"DiscoveryViewController", @"OrdersViewController", @"MineViewController"];
        _URLs = @[@"/home", @"/nearby", @"/discovery", @"/user/orders", @"/user/mine"];
        _tabBarItemTitles = @[@"首页", @"附近", @"发现", @"订单", @"我的"];
        NSMutableArray *vcs = [NSMutableArray array];
        for (NSString *c in _cls) {
            NavigationController *nav = [[NavigationController alloc] initWithRootViewController:[NSClassFromString(c) new]];
            [vcs addObject:nav];
            nav.tabBarItem.title = _tabBarItemTitles[[_cls indexOfObject:c]];
            [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blueColor]} forState:UIControlStateSelected];
            [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]} forState:UIControlStateNormal];
        }
        self.viewControllers = vcs;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSUInteger index = [self.viewControllers indexOfObject:viewController];

    NSString *URL = _URLs[index];
    ZYRouter.URL(URL).completionHandler(^(RouteResponse *response){
        NSLog(@"%@", response);
    }).route();
    
    return NO;
}

@end
