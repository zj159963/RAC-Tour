//
//  ViewController.m
//  Part1
//
//  Created by yicha on 10/29/15.
//  Copyright © 2015 Z.Chris. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()

@property (nonatomic, weak, nullable) IBOutlet UITextField *userNameField;
@property (nonatomic, weak, nullable) IBOutlet UITextField *passwordField;
@property (nonatomic, weak, nullable) IBOutlet UITextField *confirmField;
@property (nonatomic, weak, nullable) IBOutlet UIButton *signUpButton;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // 转换userNameField.rac_textSignal事件流，发出userNameField输入是否合法的信号，通过订阅这个事件流，根据信号量更新userNameField的背景色
  // 也就是说，每次有新的输入，我们都可以收到新的信号，从而处理逻辑
  RACSignal *userNameSignal = [self.userNameField.rac_textSignal map:^id(NSString *text) {
    return @(isValidInput(text, 3));
  }];
  // 同userNameField
  RACSignal *passwordSignal = [self.passwordField.rac_textSignal map:^id(NSString *text) {
    return @(isValidInput(text, 5));
  }];
  
  // 将passwordSignal和confirmField,rac_textSignal组合，每次passwordField或者confirmField有新的输入，订阅这个事件流后，我们都会接收到组合之后的事件流发出的信号
  // reduce方法，将组合起来的信号，简化成一个新的信号输入，订阅这个事件流，修改confirmField背景色
  RACSignal *confirmSignal = [RACSignal combineLatest:@[passwordSignal, self.confirmField.rac_textSignal] reduce:^id(NSNumber *passwordValid, NSString *text) {
    return @([text isEqualToString:self.passwordField.text] && passwordValid.boolValue);
  }];
  
  // 订阅上述事件流，更新背景色
  [userNameSignal subscribeNext:^(NSNumber *valid) {
    self.userNameField.backgroundColor = colorWithFlag(valid.boolValue);
  }];
  [passwordSignal subscribeNext:^(NSNumber *valid) {
    self.passwordField.backgroundColor = colorWithFlag(valid.boolValue);
  }];
  [confirmSignal subscribeNext:^(NSNumber *flag) {
  self.confirmField.backgroundColor = colorWithFlag(flag.boolValue);
  }];
  
  // 将userNameSignal、passwordFieldSignal、confirmSignal组合，然后简化，得到我们想要的结果，信号量代表的含义即为 -> 满足条件，按钮可点； 不满足条件，按钮不可点
  // 订阅这个事件流，处理逻辑
  [[RACSignal
   combineLatest:@[userNameSignal, passwordSignal, confirmSignal]
    reduce:^id(NSNumber *userNameValid, NSNumber *passwordValid, NSNumber *confirmValid) {
    return @(userNameValid.boolValue && passwordValid.boolValue && confirmValid.boolValue);
  }]
    subscribeNext:^(NSNumber *allValid) {
    self.signUpButton.enabled = allValid.boolValue;
  }];
    
  // 可以理解为，每次touch up inside的时候，都会发出一个信号
  // ran_signalForControlEvents:方法，返回一个事件流
  //  如果感兴趣，可以试一试将这个事件流与其他的事件流组合到一块，看看能做些什么， 想想无极限么 :)
  [self.signUpButton rac_signalForControlEvents:UIControlEventTouchUpInside];
  

}

// 根据给定的字符串和长度，判断用户输入是否合法
BOOL isValidInput(NSString *input, NSUInteger givenLength) {
  return input.length > givenLength;
}

// 根据给定的标识，返回UIColor对象，yes返回白色，no 返回黄色
UIColor * colorWithFlag(BOOL flag) {
  return flag ? [UIColor whiteColor] : [UIColor yellowColor];
}

/*
 - (IBAction)didChangedUserNameFieldEditing:(id)sender {
 self.userNameField.backgroundColor = [self isValidUserName] ? [UIColor whiteColor] : [UIColor yellowColor];
 self.signUpButton.enabled = [self shouldSignUp];
 }
 
 - (IBAction)didChangedPasswordFieldEditing:(id)sender {
 self.passwordField.backgroundColor = [self isValidPassword] ? [UIColor whiteColor] : [UIColor yellowColor];
 self.confirmField.backgroundColor = [self isValidConfirm] ? [UIColor whiteColor] : [UIColor yellowColor];
 self.signUpButton.enabled = [self shouldSignUp];
 }
 
 - (IBAction)didChangedConfirmFieldEditing:(id)sender {
 self.confirmField.backgroundColor = [self isValidConfirm] ? [UIColor whiteColor] : [UIColor yellowColor];
 self.signUpButton.enabled = [self shouldSignUp];
 }
 
 - (BOOL)isValidUserName {
 return self.userNameField.text.length > 3;
 }
 
 - (BOOL)isValidPassword {
 return self.passwordField.text.length > 5;
 }
 
 - (BOOL)isValidConfirm {
 return [self isValidPassword] && [self.confirmField.text isEqualToString:self.passwordField.text];
 }
 
 - (BOOL)shouldSignUp {
 return [self isValidUserName] && [self isValidPassword] && [self isValidConfirm];
 }
 */

@end
