//
//  XPYHomepageTableViewController.m
//  XPYVideoProcessingDemo
//
//  Created by 项林平 on 2021/9/16.
//

#import "XPYHomepageTableViewController.h"
#import "XPYVideosSplicingViewController.h"


@interface XPYHomepageTableViewController ()

@end

@implementation XPYHomepageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XPYHomepageCell" forIndexPath:indexPath];
    
    cell.textLabel.text = @"视频拼接";
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XPYVideosSplicingViewController *videoSplicingController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"XPYVideosSplicingController"];
    [self.navigationController pushViewController:videoSplicingController animated:YES];
}


@end
