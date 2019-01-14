//
//  SignalOperationController.m
//  ReactiveCocoa
//
//  Created by apple on 2019/1/14.
//  Copyright © 2019 liyayun. All rights reserved.
//

#import "SignalOperationController.h"
#import "ReactiveObjC.h"
#import "Masonry.h"

@interface SignalOperationController ()

@property(nonatomic,strong)UITextField *textField_1;
@property(nonatomic,strong)UITextField *textField_2;
@property(nonatomic,strong)UIButton *button;
@end

@implementation SignalOperationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITextField *textField = [UITextField new];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"请输入账号";
    [self.view addSubview:textField];
    self.textField_1 = textField;
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.view).offset(100);
        make.height.mas_equalTo(40);
    }];
    
    UITextField *textField_2 = [UITextField new];
    textField_2.borderStyle = UITextBorderStyleRoundedRect;
    textField_2.placeholder = @"请输入密码";
    [self.view addSubview:textField_2];
    self.textField_2 = textField_2;
    [textField_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(textField);
        make.top.equalTo(textField.mas_bottom).offset(40);
    }];
    
    UIButton *button = [UIButton new];
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:@"test" forState:UIControlStateNormal];
    [self.view addSubview:button];
    self.button = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(200);
        make.top.equalTo(textField_2.mas_bottom).offset(50);
    }];
    
    [self map];
    [self flattenMap];
    [self merge];
    [self takeLast];
    [self filter];
    [self ignore];
    [self distinctUntilChanged];
    [self concat];
    [self then];
    [self zipWith];
    [self takeUntil];
    [self skip];
    [self switchToLatest];
    [self doOperation];
    [self interval];
    [self delay];
    [self retry];
    [self replay];
    [self throttle];
}

/// 信号合并，只有当所有信号都sendNext一次后才能触发合并后的信号
- (void)combineLatest {
    
    RACSignal *buttonSignal = [self.button rac_signalForControlEvents:UIControlEventTouchUpInside];
    @weakify(self);
    [[RACSignal combineLatest:@[self.textField_1.rac_textSignal,self.textField_2.rac_textSignal,buttonSignal]]subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"combineLatest");
        @strongify(self);
        [self reduce];
    }];
}

/// 将元组里面的值全都取出来，对值做一些操作，再合成一个值返回
- (void)reduce {
    
    @weakify(self);
    [[[RACSignal combineLatest:@[self.textField_1.rac_textSignal,self.textField_2.rac_textSignal]] reduceEach:^id _Nonnull(NSString *account,NSString *pwd){
        return @(account.length > 10 && pwd.length > 5);
    }] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.button.backgroundColor = [x boolValue] ? [UIColor blueColor] : [UIColor lightGrayColor];
    }];
}

/// 值映射，将值映射成一个新值返回
- (void)map {
    
    @weakify(self);
    [[[self.textField_1 rac_textSignal]map:^id _Nullable(NSString * _Nullable value) {
        return @(value.length > 0);
    }] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.textField_2.hidden = ![x boolValue];
    }];
}

/// 信号i映射，拿到信号中的值处理后隐射成一个新信号返回
- (void)flattenMap {
    [[[self.textField_2 rac_textSignal]flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        value = [NSString stringWithFormat:@"flattenMap:%@",value];
        return [RACSignal return:value];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"flattenMap:%@",x);
    }];
}

/// 信号绑定，多个信号绑定在一起，任何一个信号有新值就会触发
- (void)merge {
    [[self.textField_1.rac_textSignal merge:self.textField_2.rac_textSignal]subscribeNext:^(id  _Nullable x) {
        NSLog(@"merge:%@",x);
    }];
}

/// 获取N次信号
- (void)take {
    [[[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] take:3]subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"take:clicked");
    }];
}

/// 取最后N次信号，订阅者必须调用完成，这样才能确认最后N次信号
- (void)takeLast {
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{}];
    }] takeLast:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"takeLast:%@",x);
    }];
}

/// 满足条件的值才会触发信号
- (void)filter {
    [[self.textField_1.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return [value integerValue] % 2 == 0;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"filter:%@",x);
    }];
}

/// 忽略掉特定的值
- (void)ignore {
    [[self.textField_1.rac_textSignal ignore:@"4"]subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"ignore:%@",x);
    }];
}

/// 监听到值有变化才会f触发信号
- (void)distinctUntilChanged {
    [[self.textField_1.rac_textSignal distinctUntilChanged]subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"distinctUntilChanged:%@",x);
    }];
}

/// 按顺序拼接信号，上一个信号完成，下一个信号才会触发
- (void)concat {
    /// 错误示范
    [[self.textField_1.rac_textSignal concat:self.textField_2.rac_textSignal]subscribeNext:^(id  _Nullable x) {
        NSLog(@"concat：%@",x);//不会打印self.textField_2的值，因为self.textField_1没有sendCompleted
    }];
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"sendCompleted"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
    
    RACSignal *concatSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"concatSignal"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
    
    [[signal concat:concatSignal] subscribeNext:^(id  _Nullable x) {
       NSLog(@"concat：%@",x);
    }];

}

/// 拼接信号，前一个信号调用sendCompleted，才会触发后面的信号
- (void)then {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"sendCompleted"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
    
    RACSignal *thenSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"thenSignal"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
    
    [[signal then:^RACSignal * _Nonnull{
        return thenSignal;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"then:%@",x);
    }];
}

/// 将两个信号x压缩成一个信号，且必须两个都触发相同次数
- (void)zipWith {
    
    [[self.textField_2.rac_textSignal zipWith:self.textField_1.rac_textSignal]subscribeNext:^(RACTwoTuple<NSString *,id> * _Nullable x) {
        NSLog(@"zipWith:%@",x);
    }];
}

/// 直到某个信号触发不再监听
- (void)takeUntil {
    
    [[self.textField_1.rac_textSignal takeUntil:[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"takeUntil:%@",x);
    }];
}

/// 跳过前面N次信号
- (void)skip {
    [[[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]skip:2]subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"skip:%@",x);
    }];
}

/// 用来接收信号发出的信号
- (void)switchToLatest {
    RACSubject *subjectA = [RACSubject subject];
    RACSubject *subjectB = [RACSubject subject];
    
    [subjectA.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"switchToLatest：%@",x);
    }];
    
    [subjectA sendNext:subjectB];
    [subjectB sendNext:@"b"];
}

/// 发送信号前
- (void)doOperation {
    [[[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"doOperation"];
        //        [subscriber sendError:[NSError new]];
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id  _Nullable x) {
        NSLog(@"doNext:%@",x);///sendNext: 执行后先走这个block，然后再执行subscribeNext:的block
    }] doError:^(NSError * _Nonnull error) {
        NSLog(@"%@",error.description);/// sendError执行后走这个block
    }] doCompleted:^{
        NSLog(@"doCompleted");/// sendCompleted执行后走这个block
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"doOperation:%@",x);
    }];
}

/// 每N秒发送一次信号
- (void)interval {
    [[[RACSignal interval:10 onScheduler:[RACScheduler scheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"%@",x);
    }];
}

/// 延时N秒发送信号
- (void)delay {
    [[[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]delay:2]subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"delay:clicked");
    }];
}

/// 重试直到成功
- (void)retry {
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        static int a = 1;
        if (a > 3) {
            [subscriber sendNext:@(a)];
        }else{
            [subscriber sendError:nil];
        }
        a++;
        return nil;
    }] retry] subscribeNext:^(id  _Nullable x) {
        NSLog(@"retry:%@",x);
    }];
}

/// 多次订阅，每次都重新执行
- (void)replay {
    __block int a = 10;
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        a++;
        [subscriber sendNext:@(a)];
        [subscriber sendCompleted];
        return nil;
    }]replay];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"first:%@",x);
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"second:%@",x);
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"second:%@",x);
    }];
    // 三次打印值都是11，去掉replay，打印值分别是11，12，13
}

/// 节流，N秒内只获取最后一次信号,N秒后才会触发
- (void)throttle {
    [[[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]throttle:0.3]subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"throttle:clicked");
    }];
}

/// 监听属性值的改变
- (void)RACObserve {
    [RACObserve(self.view,backgroundColor) subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

@end
