//
//  ContactPersonVC.m
//  AddressBookOperation
//
//  Created by 刘康蕤 on 16/1/29.
//  Copyright © 2016年 Lvcary. All rights reserved.
//

#import "ContactPersonVC.h"
#import "PopoverView.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface ContactPersonVC ()<UITableViewDataSource,UITableViewDelegate,CNContactViewControllerDelegate,CNContactPickerDelegate>

@property (weak, nonatomic) UITableView *contactTableview;

@property (nonatomic, strong)NSMutableArray *contactDataSource;

@end

@implementation ContactPersonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"contactVc";
    _contactDataSource = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tab = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    tab.delegate = self;
    tab.dataSource = self;
    [self.view addSubview:tab];
    
    _contactTableview = tab;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(rightItemAction)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadContactPerson];
}

- (void)rightItemAction{
    NSArray *nameArray = @[@"添加联系人",@"添加到已有联系人"];
    CGPoint point = CGPointMake(CGRectGetWidth(self.view.frame) - 25, 64);
    PopoverView *pop = [[PopoverView alloc] initWithPoint:point titles:nameArray images:nil];
    pop.selectRowAtIndex = ^(NSInteger index){
        
        switch (index) {
            case 0:
            {
                ///添加新的联系人
                [self addNewContactPerson];
            }
                break;
            case 1:
            {
                ///添加已有联系人
                [self addNewContactToExistingContact];
            }
                break;
                
            default:
                break;
        }
        
        
    };
    [pop show];
}

#pragma mark    tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _contactDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indefiter = @"addressBookCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indefiter];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indefiter];
    }
    cell.textLabel.text = [[_contactDataSource objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[_contactDataSource objectAtIndex:indexPath.row] objectForKey:@"phone"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark  获取联系人数据
- (void)loadContactPerson{
    NSError * error = nil;
    //
    CNContactStore * contactStore = [[CNContactStore alloc] init];
    
    //验证用户是否有权限使用手机的通讯录
    //[CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //NSLog(@"有权限访问通讯录");
        }else{
            //NSLog(@"无权限访问通讯录");
        }
    }];
    
    ///创建联系人的取出请求，可以取出联系人不同的属性内容  以下是取出联系人的性别，电话号码，名字
    CNContactFetchRequest * fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[@"familyName",@"phoneNumbers",@"givenName"]];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *dicInfoLocal = [NSMutableDictionary dictionaryWithCapacity:0];
        if (!contact.givenName) {
            [dicInfoLocal setObject:@"无名" forKey:@"name"];
        }else{
            if ([contact.givenName isEqualToString:@""]) {
                [dicInfoLocal setObject:contact.familyName forKey:@"name"];
            }else{
                [dicInfoLocal setObject:contact.givenName forKey:@"name"];
            }
            
        }
        
        ///电话号码为数组，可以用数组接收 此处就不多写
        if (contact.phoneNumbers.count > 0) {
            CNPhoneNumber * phoneNumber = [[contact.phoneNumbers objectAtIndex:0] labeledValueBySettingLabel:contact.givenName].value;
            [dicInfoLocal setObject:phoneNumber.stringValue forKey:@"phone"];
        }else{
            [dicInfoLocal setObject:@"" forKey:@"phone"];
        }
        
        [_contactDataSource addObject:dicInfoLocal];
    }];
}

///保存到新的联系人
- (void)addNewContactPerson{
    ///创建一个联系人的各个数值对象
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    
    ///设置手机号
    CNLabeledValue * phoneNumbers = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile
                                                                    value:[CNPhoneNumber phoneNumberWithStringValue:@"11111111111"]];
    contact.phoneNumbers = @[phoneNumbers];
    
    ///设置名字
    contact.givenName = @"Bob";
    
    
    CNContactViewController * addContactVc = [CNContactViewController viewControllerForNewContact:contact];
    addContactVc.delegate = self;
    
    UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:addContactVc];
    [self.parentViewController presentViewController:navi animated:YES completion:^{
        
    }];
    
}

///保存到现有的联系人
- (void)addNewContactToExistingContact{
    CNContactPickerViewController * controller = [[CNContactPickerViewController alloc] init];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

#pragma mark   CNContactViewControllerDelegate
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    if (contact) {
        //保存
    }else{
        //取消
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark   CNContactPickerDelegate
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
    //取消
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    //select
    NSLog(@"select");
    [picker dismissViewControllerAnimated:YES completion:^{
        //copy一份可写的Contact对象
        CNMutableContact *contactCopy = [contact mutableCopy];
        
        ///设置需要添加的手机号
        NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithArray:contact.phoneNumbers];
        
        CNLabeledValue * phoneNumberAdd = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMain
                                                                        value:[CNPhoneNumber phoneNumberWithStringValue:@"11111111111"]];
        [phoneNumbers addObject:phoneNumberAdd];
        contactCopy.phoneNumbers = phoneNumbers;
        
        CNContactViewController * addContactVc = [CNContactViewController viewControllerForNewContact:contactCopy];
        addContactVc.delegate = self;
        
        UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:addContactVc];
        [self.parentViewController presentViewController:navi animated:YES completion:^{
            
        }];
        
    }];
}


@end
