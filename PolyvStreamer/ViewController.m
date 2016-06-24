//
//  ViewController.m
//  PolyvStreamerDemo
//
//  Created by FT on 16/3/17.
//  Copyright © 2016年 polyv. All rights reserved.
//

#import "ViewController.h"
#import "PLVSession.h"
#import "CameraController.h"

#define TEXTFIELDWIDTH 150
#define TEXTFIELDHEIGHT 30


@interface ViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *channelIdTF;
@property (nonatomic, strong) IBOutlet UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.passwordTF.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   // [self setOrientation:UIInterfaceOrientationPortrait];     // 手动旋转屏幕
}


- (IBAction)loginButton:(id)sender {
    
    // 进行频道和密码的验证
    [PLVSession sessionLoginWithChannelId:self.channelIdTF.text password:self.passwordTF.text success:^(NSString *successInfo) {
        NSLog(@"%@",successInfo);
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UINavigationController *navCtrl = [sb instantiateViewControllerWithIdentifier:@"navigationCtl"];
        CameraController *cameraCtrl = (CameraController *)navCtrl.topViewController;
        cameraCtrl.channelId = _channelIdTF.text;
        cameraCtrl.password = _passwordTF.text;

        [self presentViewController:navCtrl animated:YES completion:nil];
        
    } failure:^(NSString *failureInfo) {
        NSLog(@"%@",failureInfo);
    }];
}


- (UITextField *)channelIdTF {
    if (!_channelIdTF) {
        _channelIdTF = [[UITextField alloc] init];
        _channelIdTF.borderStyle = UITextBorderStyleRoundedRect;
        _channelIdTF.bounds = CGRectMake(0, 0, TEXTFIELDWIDTH, TEXTFIELDHEIGHT);
        _channelIdTF.placeholder = @"请输入频道号";
        [_channelIdTF setKeyboardType:UIKeyboardTypeNumberPad];
    }
    return _channelIdTF;
}

- (UITextField *)passwordTF {
    if (!_passwordTF) {
        _passwordTF = [[UITextField alloc] init];
        _passwordTF.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTF.bounds = CGRectMake(0, 0, TEXTFIELDWIDTH, TEXTFIELDHEIGHT);
        _passwordTF.placeholder = @"请输入密码";
        [_passwordTF setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];

    }
    return _passwordTF;
}

- (void)setSubViewsframe {
    
    self.passwordTF.frame = CGRectMake(CGRectGetMidX(self.view.frame)-CGRectGetWidth(self.channelIdTF.bounds)/2, CGRectGetMinY(self.loginButton.frame) - CGRectGetHeight(self.passwordTF.bounds)-40, CGRectGetWidth(self.passwordTF.bounds), CGRectGetHeight(self.passwordTF.bounds));
    self.channelIdTF.frame = CGRectMake(CGRectGetMinX(self.passwordTF.frame), CGRectGetMinY(self.passwordTF.frame) - CGRectGetHeight(self.channelIdTF.bounds)-20, CGRectGetWidth(self.channelIdTF.bounds), CGRectGetHeight(self.channelIdTF.bounds));
}


- (void)setOrientation:(UIInterfaceOrientation)orientation {
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.passwordTF resignFirstResponder];             // return 时取消文本框第一响应者身份
    return YES;
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;                      // 设置屏幕的方向
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
