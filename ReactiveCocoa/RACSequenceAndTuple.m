//
//  RACSequenceAndTuple.m
//  ReactiveCocoa
//
//  Created by apple on 2018/11/15.
//  Copyright © 2018 liyayun. All rights reserved.
//

#import "RACSequenceAndTuple.h"
#import "ReactiveObjC.h"

@interface RACSequenceAndTuple ()

@end

@implementation RACSequenceAndTuple

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[RACSignal rac_signalForSelector:@selector(touchesBegan:withEvent:)] subscribeNext:^(RACTuple * _Nullable x) {
        [self sequenceDemo];
    }];
    
}

- (void)sequenceDemo{
    NSArray *array = @[@"666",@"888",@"lalala"];
    RACSequence *sequence = array.rac_sequence;
    RACSignal *signal = sequence.signal;
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    NSDictionary *dict = @{@"1":@"阴天",
                           @"2":@"傍晚",
                           @"3":@"coding"
                           };
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [dict.rac_keySequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [dict.rac_valueSequence.signal subscribeNext:^(id  _Nullable x) {
       NSLog(@"%@",x);
    }];

}

@end
