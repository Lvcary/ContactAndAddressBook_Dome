//
//  AddressBookVC.m
//  AddressBookOperation
//
//  Created by 刘康蕤 on 16/1/29.
//  Copyright © 2016年 Lvcary. All rights reserved.
//

#import "AddressBookVC.h"
#import "PopoverView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBookUI/ABNewPersonViewController.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
@interface AddressBookVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) UITableView *addRessTableview;

@property (nonatomic, strong)NSMutableArray *addRessDataSource;

@property (nonatomic, strong) ABNewPersonViewController * newpersonAddVc;  //添加到新的联系人

@property (nonatomic, strong) ABNewPersonViewController * newpersonExistVc; //添加到已有的联系人


@end

@implementation AddressBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"AddressBook";
    _addRessDataSource = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tab = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    tab.delegate = self;
    tab.dataSource = self;
    [self.view addSubview:tab];
    
    _addRessTableview = tab;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(rightItemAction)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadAddressBook];
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
                [self addNewPerson];
            }
                break;
            case 1:
            {
                ///添加已有联系人
                [self addNewPersonToExistingPerson];
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
    return _addRessDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *indefiter = @"addressBookCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indefiter];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indefiter];
    }
    cell.textLabel.text = [[_addRessDataSource objectAtIndex:indexPath.row] objectForKey:@"first"];
    cell.detailTextLabel.text = [[_addRessDataSource objectAtIndex:indexPath.row] objectForKey:@"telphone"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark   获取联系人
- (void)loadAddressBook{
    [_addRessDataSource removeAllObjects];
    ///取得本地通讯录名柄
    ABAddressBookRef addressBook;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
         {
             dispatch_semaphore_signal(sema);
         });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }else{
        addressBook = ABAddressBookCreate();
    }
    
    
    
    //取得本地所有联系人记录
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    //    NSLog(@"-----%d",(int)CFArrayGetCount(results));
    //    NSLog(@"in %s %d",__func__,__LINE__);
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        NSMutableDictionary *dicInfoLocal = [NSMutableDictionary dictionaryWithCapacity:0];
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        //读取firstname
        NSString *first = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if (first==nil) {
            first = @" ";
        }
        [dicInfoLocal setObject:first forKey:@"first"];
        
        NSString *last = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if (last == nil) {
            last = @" ";
        }
        [dicInfoLocal setObject:last forKey:@"last"];
        
        
        
        
        ABMultiValueRef tmlphone =  ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSString* telphone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmlphone, 0);
        if (telphone == nil) {
            telphone = @" ";
        }
        [dicInfoLocal setObject:telphone forKey:@"telphone"];
        CFRelease(tmlphone);
        
        if ([first isEqualToString:@" "] == NO || [last isEqualToString:@" "]) {
            [self.addRessDataSource addObject:dicInfoLocal];
        }
    
    }
    CFRelease(results);//new
    CFRelease(addressBook);//new
    [_addRessTableview reloadData];
    
}

#pragma mark   添加新的联系人
- (void)addNewPerson{
    NSString *name = @"jobs";
    NSString *phone = @"15245684585";
    // 创建一条空的联系人
    ABRecordRef record = ABPersonCreate();
    CFErrorRef error;
    // 设置联系人的名字
    ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)name, &error);
    // 添加联系人电话号码以及该号码对应的标签名
    ABMutableMultiValueRef mutable = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(mutable, (__bridge CFTypeRef)(phone), kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(record, kABPersonPhoneProperty, mutable, &error);
    
    _newpersonAddVc = [[ABNewPersonViewController alloc] init];
    _newpersonAddVc.newPersonViewDelegate = self;
    _newpersonAddVc.displayedPerson = record;
    CFRelease(record); // TODO check
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:_newpersonAddVc];
    [self.parentViewController presentViewController:navCtrl animated:YES completion:nil];
}

#pragma mark   添加到已有的联系人
- (void)addNewPersonToExistingPerson{
    ABPeoplePickerNavigationController * peoplePickerNaviVc = [[ABPeoplePickerNavigationController alloc] init];
    peoplePickerNaviVc.peoplePickerDelegate = self;
    [self presentViewController:peoplePickerNaviVc animated:YES completion:nil];
    
}

#pragma mark   peoplePickerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person{
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
        
        CFErrorRef error = NULL;
        CFTypeRef typeRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
        // 添加联系人电话号码以及该号码对应的标签名
        ABMutableMultiValueRef mutable;
        if (ABMultiValueGetCount(typeRef) == 0) {
            mutable = ABMultiValueCreateMutable(kABStringPropertyType);
        }else{
            mutable = ABMultiValueCreateMutableCopy (typeRef);
        }
        
        ABMultiValueAddValueAndLabel(mutable, @"22222222222", kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(person, kABPersonPhoneProperty, mutable, &error);
        
        _newpersonExistVc = [[ABNewPersonViewController alloc] init];
        _newpersonExistVc.newPersonViewDelegate = self;
        _newpersonExistVc.displayedPerson = person;

        
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:_newpersonExistVc];
        [self.parentViewController presentViewController:navCtrl animated:YES completion:nil];
    }];
}

#pragma mark   newPersonViewDeleaget
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(nullable ABRecordRef)person{
    if (person) {
        if (newPersonView == _newpersonAddVc) {

        }else{
            CFErrorRef error = NULL;
            ABMutableMultiValueRef multiValue;
            CFTypeRef typeRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
            if (ABMultiValueGetCount(typeRef) == 0)
                multiValue = ABMultiValueCreateMutable(kABStringPropertyType);
            else
                multiValue = ABMultiValueCreateMutableCopy (typeRef);
            
            ABMultiValueAddValueAndLabel(multiValue, @"22222222222", kABPersonPhoneMainLabel,NULL);
            ABAddressBookSave(newPersonView.addressBook, &error);
        }
    }
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
}

@end
