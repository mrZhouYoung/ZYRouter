//
//  HomeViewController.m
//  ZYRouter_Example
//
//  Created by Young on 2025/1/8.
//  Copyright © 2025年 Young. All rights reserved.
//

#import "HomeViewController.h"
#import "ZYRouter.h"

@interface HomeViewController ()

@end

@implementation HomeViewController {
    NSMutableArray *_data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"首页";
        
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *statusItem = [[UIBarButtonItem alloc] initWithTitle:@"状态" style:UIBarButtonItemStylePlain target:self action:@selector(status)];
    self.navigationItem.rightBarButtonItem = statusItem;
    
    self.tabBarItem.title = @"首页";
    
    _data = [NSMutableArray array];

    NSDictionary *dict;
    dict = @{@"title": @"block",
             @"detail": @"/alert?title=hello&message=world",
             @"block": ^(){
                 ZYRouter.URL(@"/alert?title=hello&message=world").route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"push",
             @"detail": @"/push",
             @"block": ^(){
                 ZYRouter.URL(@"/push").route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"present",
             @"detail": @"/present",
             @"block": ^(){
                 ZYRouter.URL(@"/present").route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"代码覆盖配置push",
             @"detail": @"/push",
             @"block": ^(){
                 ZYRouter.URL(@"/push").present().wrapIn(NSClassFromString(@"NavigationController")).route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"代码覆盖配置present",
             @"detail": @"/present",
             @"block": ^(){
                 ZYRouter.URL(@"/present").push().pushFrom(self.navigationController).route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"单个拦截器",
             @"detail": @"/mine",
             @"block": ^(){
                 ZYRouter.URL(@"/mine").route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"多个拦截器",
             @"detail": @"/buy?code=9989",
             @"block": ^(){
                 ZYRouter.URL(@"/buy?code=9989").route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"跳过所有拦截器",
             @"detail": @"/buy?code=9989",
             @"block": ^(){
                 ZYRouter.URL(@"/buy?code=9989").removeAllInterceptors().route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"跳过指定拦截器",
             @"detail": @"/buy?code=9989",
             @"block": ^(){
                 ZYRouter.URL(@"/buy?code=9989").removeInterceptors(@[NSClassFromString(@"InterceptorA")]).route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"追加拦截器",
             @"detail": @"/buy?code=9989",
             @"block": ^(){
                 ZYRouter.URL(@"/buy?code=9989").appendInterceptors(@[NSClassFromString(@"InterceptorB")]).appendInterceptorOptions(@[@{}]).appendInterceptorIndexes(@[@(10)]).route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"URL占位",
             @"detail": @"/detail/9989?type=A",
             @"block": ^(){
                 ZYRouter.URL(@"/detail/9989?type=A").route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"query匹配",
             @"detail": @"/product/list?type=A&category=hot",
             @"block": ^(){
                 ZYRouter.URL(@"/product/list?type=A&category=hot").params(@{@"s": @5}).route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"query匹配",
             @"detail": @"/product/list?type=B&category=hot",
             @"block": ^(){
                 ZYRouter.URL(@"/product/list?type=B&category=hot").route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"重定向",
             @"detail": @"/product/list?type=C",
             @"block": ^(){
                 ZYRouter.URL(@"/product/list?type=C").route();
             }
             };
    [_data addObject:dict];
    
    dict = @{@"title": @"错误页面",
             @"detail": @"/url/not/found?blabla=hahaha",
             @"block": ^(){
                 ZYRouter.URL(@"/url/not/found?blabla=hahaha").route();
             }
             };
    [_data addObject:dict];
}

- (void)status {
    ZYRouter.URL(@"/user-status").completionHandler(^(RouteResponse *response){
        NSLog(@"%@", response);
    }).route();
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    cell.textLabel.text = [_data[indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.text = [_data[indexPath.row] objectForKey:@"detail"];
    
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    void (^block)() = [_data[indexPath.row] objectForKey:@"block"];
    block();
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
