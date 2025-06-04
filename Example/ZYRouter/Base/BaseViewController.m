//
//  BaseViewController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.label = [[UILabel alloc] init];
    self.label.numberOfLines = 0;
    [self.view addSubview:self.label];
    self.label.frame = self.view.bounds;
    
    NSString *content = [NSString stringWithFormat:@"%@\n\n%@", self.zy_routeURL, self.zy_routeParams];
    self.label.text = content;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.navigationController.presentingViewController && self.navigationController.topViewController == self) {
        UIBarButtonItem *dismiss = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
        self.navigationItem.leftBarButtonItem = dismiss;
    }
}

- (void)dismiss {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
