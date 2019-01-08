
//
//  RACCommandDemo.m
//  ReactiveCocoa
//
//  Created by apple on 2018/11/14.
//  Copyright © 2018 liyayun. All rights reserved.
//

#import "RACCommandDemo.h"
#import "ReactiveObjC.h"

@interface RACCommandDemo ()
@property (strong, nonatomic)  UITextField *password;
@property (strong, nonatomic)  UITextField *password_confirm;
@property(nonatomic,strong)UIButton *btn;
@end

@implementation RACCommandDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.btn = [UIButton new];
    _btn.frame = CGRectMake(100,100, 100, 100);
    _btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:_btn];
    
    self.password= [UITextField new];
    self.password.frame = CGRectMake(100, 250, 150, 50);
    self.password.placeholder = @"输入密码";
    [self.view addSubview:self.password];
    
    self.password_confirm = [UITextField new];
    self.password_confirm.frame = CGRectMake(100, 350, 150, 50);
    self.password_confirm.placeholder = @"输入密码";
    [self.view addSubview:self.password_confirm];
    
//    [self createCommand];
    [self createEnableCommand];
}

/*
 RACCommand:响应操作（通常是UI的操作），触发信号
 input:对应绑定的UI组件
 */
- (void)createCommand
{
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"click");
//        return [RACSignal empty];
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"d"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"done");
            }];
        }];
    }];
    //executionSignals:包裹着创建command时构建的信号
    [[command executionSignals]subscribeNext:^(id  _Nullable x) {
        //x:command内部的一个信号
        [x subscribeNext:^(id  _Nullable x) {
            NSLog(@"do something");
        }];
    }];
    self.btn.rac_command = command;
    [command execute:self.btn];
    
}


- (void)createEnableCommand{
    RACSignal *enableSignal = [[RACSignal combineLatest:@[
                                                          self.password.rac_textSignal,
                                                          self.password_confirm.rac_textSignal
                                                          ]] map:^id _Nullable(RACTuple * _Nullable value) {
        return @([self.password.text isEqualToString:self.password_confirm.text]&&self.password_confirm.text.length&&self.password.text.length);
    }];
    RACCommand *enableCommand = [[RACCommand alloc]initWithEnabled:enableSignal signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"Enable click");
        return [RACSignal empty];
    }];
    [enableCommand execute:self.btn];//执行command
    self.btn.rac_command = enableCommand;
}

- (void)buttonPress
{
    UIButton *btn = [UIButton new];
    btn.frame = CGRectMake(100, 200, 100, 100);
    btn.backgroundColor = [UIColor blackColor];
    [self.view addSubview:btn];
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"button pressed");
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@""];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"信号销毁");
            }];
        }];
    }];
    btn.rac_command = command;
    [command execute:btn];
    [[command executionSignals]subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
        [x subscribeNext:^(id  _Nullable x) {
            NSLog(@"%@",x);
        }];
    }];
    [[[command executionSignals]switchToLatest]subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}
@end
