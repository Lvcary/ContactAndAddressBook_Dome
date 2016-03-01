//
//  ViewController.m
//  AddressBookOperation
//
//  Created by 刘康蕤 on 16/1/29.
//  Copyright © 2016年 Lvcary. All rights reserved.
//

#import "ViewController.h"
#import "AddressBookVC.h"
#import "ContactPersonVC.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) UITableView *tableview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"通讯录";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tab = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStyleGrouped];
    tab.delegate = self;
    tab.dataSource = self;
    [self.view addSubview:tab];
    
    _tableview = tab;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indefiter = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indefiter];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indefiter];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"AddressBook";
            break;
        case 1:
            cell.textLabel.text = @"Contact";
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            AddressBookVC * bookVc = [[AddressBookVC alloc] init];
            [self.navigationController pushViewController:bookVc animated:YES];
        }
            break;
        case 1:
        {
            ContactPersonVC * contactVc = [[ContactPersonVC alloc] init];
            [self.navigationController pushViewController:contactVc animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

@end
