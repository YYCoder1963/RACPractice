//
//  RAC_Timer_Demo.m
//  ReactiveCocoa
//
//  Created by apple on 2018/11/14.
//  Copyright © 2018 liyayun. All rights reserved.
//

#import "RAC_Timer_Demo.h"
#import "ReactiveObjC.h"


@interface RAC_Timer_Demo ()
@property (weak, nonatomic) IBOutlet UIButton *btn;
/** <#title#> */
@property(nonatomic,assign)NSInteger time;
/** <#title#> */
@property(nonatomic,strong)RACDisposable *disposable;
@end

@implementation RAC_Timer_Demo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self.btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        x.enabled = false;
        self.time = 10;
        self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
            self.time--;
            NSString *title = _time > 0 ? [NSString stringWithFormat:@"请等待%ld秒后重试",(long)_time] : @"发送验证码";
            [self.btn setTitle:title forState:UIControlStateNormal | UIControlStateDisabled];
            self.btn.enabled = (_time == 0) ? YES : NO;
            if (_time == 0) {
                [self.disposable dispose];
            }
        }];
    }];
    
}

@end
