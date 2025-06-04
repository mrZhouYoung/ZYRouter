//
//  BuyViewController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "BuyViewController.h"

@interface BuyViewController ()

@end

@implementation BuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"购买%@", self.zy_routeParams[@"code"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
