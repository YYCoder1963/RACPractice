//
//  ViewController.m
//  ReactiveCocoa
//
//  Created by apple on 2018/11/9.
//  Copyright © 2018年 liyayun. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveObjC.h"
#import "RACCommandDemo.h"
#import "RACSignalDemo.h"
#import "RAC_Timer_Demo.h"
#import "RACSequenceAndTuple.h"
#import "Person.h"

typedef void(^Block)(void);
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(copy,nonatomic)NSArray *dataArray;
@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataArray = @[@"SignalOperationController",@"RegisterViewController",@"RGBViewController",@"ExampleViewController"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseId = @"RACDemo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = NSClassFromString(self.dataArray[indexPath.row]);
    if (class) {
        UIViewController *VC = [class new];
        [self.navigationController pushViewController:VC animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
