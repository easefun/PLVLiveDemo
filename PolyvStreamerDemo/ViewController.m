//
//  ViewController.m
//  PolyvStreamerDemo
//
//  Created by FT on 16/3/17.
//  Copyright © 2016年 polyv. All rights reserved.
//

#import "ViewController.h"
#import "PLVSession.h"

#define TEXTFIELDWIDTH 150
#define TEXTFIELDHEIGHT 30


@interface ViewController ()

@property (nonatomic, strong) UITextField *channelIdTF;
@property (nonatomic, strong) UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    // 进行频道和密码的验证
//    [PLVSession sessionLoginWithChannelId:@"99778" password:@"123456" success:^(NSString *successInfo) {
//        NSLog(@"++%@",successInfo);
//    } failure:^(NSString *failureInfo) {
//        NSLog(@"--%@",failureInfo);
//    }];
    

//    [self.view addSubview:self.channelIdTF];
//    [self.view addSubview:self.passwordTF];
//    [self setSubViewsframe];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
