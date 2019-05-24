//
//  ViewController.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/27.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "LoginViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <PLVLiveAPI/PLVLiveAPI.h>
#import "PLVSettingViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *channelIdTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLable.text = @"POLYV 直播";
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLable;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonClick:(id)sender {
    [self.view endEditing:YES];

    if (!self.channelIdTF.text.length) {
        [self showAlertWithTitle:@"登录失败" message:@"请输入频道号"];
        return;
    }
    if (!self.passwordTF.text.length) {
        [self showAlertWithTitle:@"登录失败" message:@"请输入密码"];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PLVLiveAPI loadPushInfoWithChannelId:self.channelIdTF.text.integerValue password:self.passwordTF.text completion:^(PLVPushChannel *channel, NSString *rtmpUrl) {
        [hud hideAnimated:YES];
        
        NSString *liveScene = channel.channelDict[@"liveScene"];
        if ([liveScene isEqualToString:@"alone"] || [liveScene isEqualToString:@"topclass"]) {
            [PLVRtmpSetting rtmpSettingWithPushChannel:channel rtmpUrl:rtmpUrl];
            [weakSelf.navigationController pushViewController:[PLVSettingViewController new] animated:YES];
        } else {
            [weakSelf showAlertWithTitle:nil message:@"请使用普通直播场景频道登录"];
        }
    } failure:^(PLVLiveErrorCode errorCode, NSString *description) {
        [hud hideAnimated:YES];
        [weakSelf showAlertWithTitle:NameStringWithLiveErrorCode(errorCode) message:description];
    }];
}

#pragma mark - Private

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - View Control

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
