//
//  ViewController.m
//  PolyvStreamerDemo
//
//  Created by ftao on 16/3/17.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "ViewController.h"
#import "PLVSession.h"
#import "CameraController.h"


@interface ViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *channelIdTF;
@property (nonatomic, strong) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
   // [self setOrientation:UIInterfaceOrientationPortrait];     // 手动旋转屏幕
}


- (IBAction)loginButton:(id)sender {
    
    // 频道号和密码验证
    [PLVSession sessionLoginWithChannelId:self.channelIdTF.text password:self.passwordTF.text success:^(NSString *successInfo) {
        NSLog(@"%@",successInfo);
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UINavigationController *navCtrl = [sb instantiateViewControllerWithIdentifier:@"navigationCtrl"];
        CameraController *cameraCtrl = (CameraController *)navCtrl.topViewController;
        cameraCtrl.channelId = _channelIdTF.text;
        cameraCtrl.password = _passwordTF.text;
        // 回主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:navCtrl animated:YES completion:nil];
        });
    } failure:^(NSString *failureInfo) {
        //NSLog(@"%@",failureInfo);
        
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:nil message:failureInfo preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertCtrl addAction:okAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alertCtrl animated:nil completion:nil];
        });
    }];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.passwordTF resignFirstResponder];             // return 时取消文本框第一响应者身份
    return YES;
}

// 旋转屏幕方向
- (void)setOrientation:(UIInterfaceOrientation)orientation {
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
