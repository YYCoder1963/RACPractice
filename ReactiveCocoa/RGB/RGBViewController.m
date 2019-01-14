//
//  RGBViewController.m
//  ReactiveCocoa
//
//  Created by apple on 2019/1/10.
//  Copyright © 2019 liyayun. All rights reserved.
//

#import "RGBViewController.h"
#import "ReactiveObjC.h"

@interface RGBViewController ()

@property (weak, nonatomic) IBOutlet UILabel *RGBLabel;
@property (weak, nonatomic) IBOutlet UISlider *R_slider;
@property (weak, nonatomic) IBOutlet UISlider *G_slider;
@property (weak, nonatomic) IBOutlet UISlider *B_slider;
@property (weak, nonatomic) IBOutlet UITextField *R_textField;
@property (weak, nonatomic) IBOutlet UITextField *G_textField;
@property (weak, nonatomic) IBOutlet UITextField *B_textField;

@property(assign,nonatomic)CGFloat r;
@property(assign,nonatomic)CGFloat g;
@property(assign,nonatomic)CGFloat b;

@end

@implementation RGBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.R_textField.text = @"0.50";
    self.G_textField.text = @"0.50";
    self.B_textField.text = @"0.50";
    
    
    RACSignal *r_signal = [self bindSlider:self.R_slider withTextField:self.R_textField];
    RACSignal *g_signal = [self bindSlider:self.G_slider withTextField:self.G_textField];
    RACSignal *b_signal = [self bindSlider:self.B_slider withTextField:self.B_textField];
    
    RACSignal *colorSignal = [[RACSignal combineLatest:@[r_signal,g_signal,b_signal]]map:^id _Nullable(RACTuple * _Nullable value) {
        return [UIColor colorWithRed:[value[0] floatValue] green:[value[1] floatValue] blue:[value[2] floatValue] alpha:1];
    }];
    
    @weakify(self);
    [colorSignal subscribeNext:^(UIColor * _Nullable x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.RGBLabel.backgroundColor = x;
        });
    }];
    
    
}

- (RACSignal *)bindSlider:(UISlider *)slider withTextField:(UITextField *)textField {
    
    RACChannelTerminal *sliderChannelTerminal = [slider rac_newValueChannelWithNilValue:nil];
    RACChannelTerminal *textFieldChannelTerminal = [textField rac_newTextChannel];
    
    [[sliderChannelTerminal map:^id _Nullable(id  _Nullable value) {
        return [NSString stringWithFormat:@"%.2f",[value floatValue]];
    }] subscribe:textFieldChannelTerminal];
    
    [textFieldChannelTerminal subscribe:sliderChannelTerminal];
    
    RACSignal *textSignal = textField.rac_textSignal;
    
    return [[sliderChannelTerminal merge:textFieldChannelTerminal] merge:textSignal];
}


@end
