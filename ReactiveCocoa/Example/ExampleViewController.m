//
//  ExampleViewController.m
//  ReactiveCocoa
//
//  Created by apple on 2019/1/11.
//  Copyright © 2019 liyayun. All rights reserved.
//

#import "ExampleViewController.h"
#import "ReactiveObjC.h"
#import "RACCommandDemo.h"
#import "RACSignalDemo.h"
#import "RAC_Timer_Demo.h"
#import "RACSequenceAndTuple.h"
#import "Person.h"

@interface ExampleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *password_confirm;
@property (weak, nonatomic) IBOutlet UIButton *login;
@property(nonatomic,assign)BOOL createEnabled;
@property(nonatomic,strong)UIButton *btn;
@property(nonatomic,copy)NSString *userName;
@property(nonatomic,strong)UIImageView *imageView;

@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self asynchronousNetworkOperation];
}

- (void)KVOObserver
{
    Person *person = [Person new];
    RACSignal *signal1 = [person rac_valuesForKeyPath:@"name" observer:self];
    [signal1 subscribeNext:^(id  _Nullable x) {
        NSLog(@"no filter --- %@",x);
    }];
    RACSignal *signal2 = [[person rac_valuesForKeyPath:@"name" observer:self] filter:^BOOL(id  _Nullable value) {
        return [value hasPrefix:@"j"];
    }];
    [signal2 subscribeNext:^(id  _Nullable x) {
        NSLog(@"filter --- %@",x);
    }];
    
    person.name = @"lyy";
    
    person.name = @"jack";
    NSLog(@"%d",self.createEnabled);
    RAC(self,createEnabled) = [RACSignal combineLatest:@[signal1,signal2] reduce:^(NSString *name1,NSString *name2){
        return @([name1 isEqualToString:name2]);
    }];
}



- (void)asynchronousNetworkOperation{
    UIButton *loginButton = [UIButton new];
    loginButton.frame = CGRectMake(100, 300, 100, 50);
    loginButton.backgroundColor = [UIColor redColor];
    RACCommand *loginCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [self logIn];
    }];
    [loginCommand.executionSignals subscribeNext:^(RACSignal *loginSignal) {
        [loginSignal subscribeCompleted:^{
            NSLog(@"logged in");
        }];
    }];
    loginButton.rac_command = loginCommand;
    [self.view addSubview:loginButton];
}
- (RACSignal *)logIn{
    return [RACSignal empty];
}

- (void)groupOfOperations{
    [[RACSignal merge:@[[self fetchUserInfo],[self fetchOrgrepos]]] subscribeCompleted:^{
        NSLog(@"all finished");
    }];
}

- (RACSignal *)fetchUserInfo{
    for (NSInteger i = 0; i < 100; i++) {
        
    }
    return [RACSignal empty];
}
- (RACSignal *)fetchOrgrepos{
    return [RACSignal empty];
}

- (void)sequentiallyExecuteAsynchronousOperations{
    [[[[self getUserName]
       flattenMap:^__kindof RACSignal * _Nullable(NSString *value) {
           NSLog(@"getName: %@",value);
           return [self getMessage];
       }]
      flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
          NSLog(@"getMessage: %@",value);
          return [self getMessage];
      }]
     subscribeNext:^(NSString *newMessage) {
         NSLog(@"newMessage:%@",newMessage);
     } completed:^{
         NSLog(@"all done");
     }];
}
- (RACSignal *)getUserName{
    self.userName = @"lyy";
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:self.userName];
        [subscriber sendCompleted];
        return nil;
    }];
    return signal;
}
- (RACSignal *)getMessage{
    NSString *message = @"new message";
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:message];
        [subscriber sendCompleted];
        return nil;
    }];
    return signal;
}

- (RACSignal *)downloadImage{
    NSURL *imageUrl = [[NSURL alloc]initWithString:@"https://cdn02.xianglin.cn/d25b0ff4364f11ff7482dbe161ffcc27-60328.jpg"];
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:imageUrl];
        [subscriber sendCompleted];
        return nil;
    }];
    return signal;
}

- (void)downloadImageRACScheduler{
    RAC(self.imageView,image) = [[[[self downloadImage]
                                   deliverOn:[RACScheduler scheduler]]
                                  map:^id _Nullable(id  _Nullable value) {
                                      return [[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:value]];
                                  }]
                                 deliverOn:RACScheduler.mainThreadScheduler];
}

- (void)loginDemo{
    RACSignal *enableSignal = [[RACSignal combineLatest:@[
                                                          self.password_confirm.rac_textSignal,
                                                          self.password.rac_textSignal,
                                                          ]]map:^id _Nullable(RACTuple * _Nullable value) {
        return @([value[0] isEqualToString:value[1]]&& [value[0] length] && [value[1] length]);
    }] ;
    
    self.login.rac_command = [[RACCommand alloc]initWithEnabled:enableSignal signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"logan");
        return [RACSignal empty];
    }];
}
- (void)loginDemo1{
    RACSignal *enableSignal = [RACSignal combineLatest:@[
                                                         self.password.rac_textSignal,
                                                         self.password_confirm.rac_textSignal,
                                                         ] reduce:^(NSString *password,NSString *password_confirm){
                                                             return @([password_confirm isEqualToString:password]);
                                                         }];
    
    self.login.rac_command = [[RACCommand alloc]initWithEnabled:enableSignal  signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"logan");
        return [RACSignal empty];
    }];
}

- (void)test {
    UIImageView *btn = [UIImageView new];
    btn.frame = CGRectMake(100, 100, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    self.imageView = btn;
    self.login.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        RACSequenceAndTuple *demo = [RACSequenceAndTuple new];
        [self.navigationController pushViewController:demo animated:YES];
        return [RACSignal empty];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self loginDemo1];
    [self.view endEditing:YES];
}
@end
