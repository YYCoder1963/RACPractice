//
//  RACSignalDemo.m
//  ReactiveCocoa
//
//  Created by apple on 2018/11/14.
//  Copyright © 2018 liyayun. All rights reserved.
//

#import "RACSignalDemo.h"
#import "ReactiveObjC.h"

@interface RACSignalDemo ()

@end

@implementation RACSignalDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.v
    self.view.backgroundColor = [UIColor whiteColor];
    [self learnBind];
}

- (void)learnBind{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"signal");
        }];
    }];
    
    RACSignal *bindSignal = [signal bind:^RACSignalBindBlock _Nonnull{
        return ^(NSNumber *value,BOOL *stop){
            value =  @(value.integerValue * value.integerValue);
            return [RACSignal return:value];
        };
    }];
    
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}
@end
