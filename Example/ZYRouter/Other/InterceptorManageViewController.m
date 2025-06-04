//
//  InterceptorManageViewController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "InterceptorManageViewController.h"
#import "TableViewCell.h"
#import "ZYRouter.h"
#import "User.h"

@interface InterceptorManageViewController ()

@end

@implementation InterceptorManageViewController {
    NSMutableArray *_data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"cell"];
    self.navigationItem.title = @"状态管理";
    
    [self prepareData];
}

- (void)prepareData {
    _data = [NSMutableArray array];
    
    User *user = [User currentUser];
    
    NSMutableDictionary *login = [NSMutableDictionary dictionary];
    login[@"title"] = @"登录状态";
    if (user) {
        login[@"detail"] = [NSString stringWithFormat:@"uid:%@ token:%@", user.uid, user.token];
    } else {
        login[@"detail"] = @"未登录";
    }
    
    NSMutableDictionary *a = [NSMutableDictionary dictionary];
    a[@"title"] = @"拦截器A";
    if (user) {
        switch (user.a.intValue) {
            case -1:
                a[@"detail"] = @"pending";
                break;
            case 0:
                a[@"detail"] = @"失败";
                break;
            case 1:
                a[@"detail"] = @"成功";
                break;
            default:
                break;
        }
    } else {
        a[@"detail"] = @"未登录";
    }
    
    NSMutableDictionary *b = [NSMutableDictionary dictionary];
    b[@"title"] = @"拦截器B";
    if (user) {
        switch (user.b.intValue) {
            case -1:
                b[@"detail"] = @"pending";
                break;
            case 0:
                b[@"detail"] = @"失败";
                break;
            case 1:
                b[@"detail"] = @"成功";
                break;
            default:
                break;
        }
    } else {
        b[@"detail"] = @"未登录";
    }
    
    NSMutableDictionary *c = [NSMutableDictionary dictionary];
    c[@"title"] = @"风险测评";
    if (user) {
        switch (user.c.intValue) {
            case -1:
                c[@"detail"] = @"pending";
                break;
            case 0:
                c[@"detail"] = @"成功";
                break;
            case 1:
                c[@"detail"] = @"失败";
                break;
            default:
                break;
        }
    } else {
        c[@"detail"] = @"未登录";
    }
    
    [_data addObject:login];
    [_data addObject:a];
    [_data addObject:b];
    [_data addObject:c];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    cell.textLabel.text = [[_data objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.text = [[_data objectAtIndex:indexPath.row] objectForKey:@"detail"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您要退出当前账户吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *quit = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [User logout];
                [self prepareData];
                [self.tableView reloadData];
            }];
            [alert addAction:cancel];
            [alert addAction:quit];
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
            }
            break;
        case 1: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"切换拦截器A状态至" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *a = [UIAlertAction actionWithTitle:@"成功" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [User currentUser].a = @(1);
                [self prepareData];
                [self.tableView reloadData];
            }];
            UIAlertAction *b = [UIAlertAction actionWithTitle:@"失败" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [User currentUser].a = @(0);
                [self prepareData];
                [self.tableView reloadData];
            }];
            UIAlertAction *c = [UIAlertAction actionWithTitle:@"pending" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [User currentUser].a = @(-1);
                [self prepareData];
                [self.tableView reloadData];
            }];
            [alert addAction:cancel];
            [alert addAction:a];
            [alert addAction:b];
            [alert addAction:c];
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
            break;
        case 2: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"切换银行卡绑定状态至" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *a = [UIAlertAction actionWithTitle:@"已绑卡" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[User currentUser] addBankCard:@"622848194738709900"];
                [self prepareData];
                [self.tableView reloadData];
            }];
            UIAlertAction *b = [UIAlertAction actionWithTitle:@"未绑卡" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[User currentUser] addBankCard:@""];
                [self prepareData];
                [self.tableView reloadData];
            }];
            [alert addAction:cancel];
            [alert addAction:a];
            [alert addAction:b];
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
            break;
        case 3: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"切换风险测评状态至" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *a = [UIAlertAction actionWithTitle:@"已过期" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[User currentUser] riskLevelTestedAt:@(-1)];
                [self prepareData];
                [self.tableView reloadData];
            }];
            UIAlertAction *b = [UIAlertAction actionWithTitle:@"未测评" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[User currentUser] riskLevelTestedAt:@(0)];
                [self prepareData];
                [self.tableView reloadData];
            }];
            UIAlertAction *c = [UIAlertAction actionWithTitle:@"低风险" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[User currentUser] riskLevelTestedAt:@(1)];
                [self prepareData];
                [self.tableView reloadData];
            }];
            UIAlertAction *d = [UIAlertAction actionWithTitle:@"中风险" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[User currentUser] riskLevelTestedAt:@(2)];
                [self prepareData];
                [self.tableView reloadData];
            }];
            UIAlertAction *e = [UIAlertAction actionWithTitle:@"高风险" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[User currentUser] riskLevelTestedAt:@(3)];
                [self prepareData];
                [self.tableView reloadData];
            }];
            [alert addAction:cancel];
            [alert addAction:a];
            [alert addAction:b];
            [alert addAction:c];
            [alert addAction:d];
            [alert addAction:e];
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
