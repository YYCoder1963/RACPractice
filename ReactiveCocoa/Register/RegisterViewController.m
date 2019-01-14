//
//  LoginViewController.m
//  ReactiveCocoa
//
//  Created by apple on 2019/1/9.
//  Copyright © 2019 liyayun. All rights reserved.
//

#import "RegisterViewController.h"
#import "ReactiveObjC.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    @weakify(self)
    RACSignal *accountSignal = [self.accountTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @(value.length > 10);
    }];
    
    RACSignal *passwordSignal = [self.passwordTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @(value.length > 5);
    }];
    
    RACSignal *confirmSignal = [self.confirmTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @(value.length > 5);
    }];
    
    
    RACSignal *enableSignal = [[RACSignal combineLatest:@[self.accountTextField.rac_textSignal,self.passwordTextField.rac_textSignal,self.confirmTextField.rac_textSignal]] map:^id _Nullable(RACTuple * _Nullable value) {
        @strongify(self);
        return @([value[0] length] > 10 &&
                 [value[1] length] > 5 &&
                 [value[1] length] > 5 &&
        [self.passwordTextField.text isEqualToString:self.confirmTextField.text]);
    }];
    
    RAC(self.accountTextField,textColor) = [accountSignal map:^id _Nullable(id  _Nullable value) {
        NSLog(@"%@",value);
        return [value boolValue] ? [UIColor blackColor] : [UIColor lightGrayColor];
    }];
    
    RAC(self.passwordTextField,textColor) = [passwordSignal map:^id _Nullable(id  _Nullable value) {
        NSLog(@"%@",value);
        return [value boolValue] ? [UIColor blackColor] : [UIColor lightGrayColor];
    }];
    
    RAC(self.confirmTextField,textColor) = [confirmSignal map:^id _Nullable(id  _Nullable value) {
        return [value boolValue] ? [UIColor blackColor] : [UIColor lightGrayColor];
    }];
    
    RAC(self.registerButton,userInteractionEnabled) = [enableSignal map:^id _Nullable(id  _Nullable value) {
        return value;
    }];
    
    RAC(self.registerButton,backgroundColor) = [enableSignal map:^id _Nullable(id  _Nullable value) {
        return [value boolValue] ? [UIColor blueColor] : [UIColor lightGrayColor];
    }];
    
    [[self.registerButton rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"register");
    }];
    
}




@end
