//
//  PLVLiveViewController.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVLiveViewController.h"
#import <PLVLiveAPI/PLVLiveAPI.h>
#import <PLVLiveAPI/PLVLiveConfig.h>
#import <PLVSocketAPI/PLVSocketAPI.h>
#import "PLVLivePreview.h"
#import "PLVRtmpSetting.h"
#import "ZJZDanMu.h"

@interface PLVLiveViewController () <PLVSocketIODelegate>

@property (nonatomic, strong) PLVSocketIO *socketIO;
@property (nonatomic, strong) PLVSocketObject *login;   // Socket 聊天室登录对象

@property (nonatomic, strong) PLVLivePreview *livePreview;
@property (nonatomic, strong) ZJZDanMu *danmuLayer;

@property (nonatomic, assign) NSUInteger channelId;

@end

@implementation PLVLiveViewController

#pragma mark - Life Cycle

-(void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.channelId = [[PLVRtmpSetting sharedRtmpSetting].channelId integerValue];
    
    [self setupUI];
    [self loadAuthorizationInfo];
    [self configDanmu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.livePreview setupSeesion];
}

#pragma mark - Init

- (void)setupUI {
    CGRect viewFrame = self.view.bounds;
    if ([PLVRtmpSetting sharedRtmpSetting].landscapeMode) {
        viewFrame = CGRectMake(0, 0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
    }
    self.livePreview = [[PLVLivePreview alloc] initWithFrame:viewFrame];
    [self.view addSubview:self.livePreview];
}

- (void)loadAuthorizationInfo {
    __weak typeof(self)weakSelf = self;
    PLVRtmpSetting *setting = [PLVRtmpSetting sharedRtmpSetting];
    [PLVLiveAPI requestAuthorizationForLinkingSocketWithChannelId:self.channelId Appld:setting.appId appSecret:setting.appSecret success:^(NSDictionary *responseDict) {
        [weakSelf initSocketWithToken:responseDict[@"chat_token"]];
    } failure:^(PLVLiveErrorCode errorCode, NSString *description) {
        NSString *message = [NSString stringWithFormat:@"name:%@, reason:%@",NameStringWithLiveErrorCode(errorCode),description];
        [weakSelf showAlertWithTitle:@"聊天室未连接" message:message];
    }];
}

- (void)configDanmu {
    CGRect bounds = self.livePreview.bounds;
    self.danmuLayer = [[ZJZDanMu alloc] initWithFrame:CGRectMake(0, 20, bounds.size.width, bounds.size.height-20)];
    [self.livePreview insertSubview:self.danmuLayer atIndex:0];
}

- (void)insertDanmu:(NSString *)content {
    if (self.danmuLayer && content && content.length) {
        [self.danmuLayer insertDML:content];
    }
}

#pragma mark - Socket

- (void)initSocketWithToken:(NSString *)token {
    self.socketIO = [[PLVSocketIO alloc] initSocketIOWithConnectToken:token enableLog:NO];
    self.socketIO.delegate = self;
    [self.socketIO connect];
    //self.socketIO.debugMode = YES;
    
    NSString *nickName = @"主持人";
    PLVRtmpSetting *setting = [PLVRtmpSetting sharedRtmpSetting];
    if (!setting.isMasterAccount) {
        nickName = setting.channelAccountList[setting.accountId];
    }
    
    self.login = [PLVSocketObject socketObjectForLoginEventWithRoomId:self.channelId nickName:nickName avatar:nil userType:PLVSocketObjectUserTypeTeacher];
}

- (void)clearSocketIO {
    if (self.socketIO) {
        [self.socketIO disconnect];
        [self.socketIO removeAllHandlers];
        self.socketIO = nil;
    }
}

#pragma mark - <PLVSocketIODelegate>

- (void)socketIO:(PLVSocketIO *)socketIO didConnectWithInfo:(NSString *)info {
    NSLog(@"%@--%@",NSStringFromSelector(_cmd),info);
    [socketIO emitMessageWithSocketObject:self.login];       // 登录聊天室
}

- (void)socketIO:(PLVSocketIO *)socketIO didUserStateChange:(PLVSocketUserState)userState {
    NSLog(@"%s %ld", __FUNCTION__, userState);
}

- (void)socketIO:(PLVSocketIO *)socketIO didReceivePublicChatMessage:(PLVSocketChatRoomObject *)chatObject {
    //NSLog(@"%@--type:%lu, event:%@",NSStringFromSelector(_cmd),chatObject.eventType,chatObject.event);
    
    NSDictionary *user = chatObject.jsonDict[PLVSocketIOChatRoom_SPEAK_userKey];
    switch (chatObject.eventType) {
        case PLVSocketChatRoomEventType_LOGIN: {  // 用户登录
        } break;
        case PLVSocketChatRoomEventType_GONGGAO: {  // 管理员发言
            NSString *content = chatObject.jsonDict[PLVSocketIOChatRoom_GONGGAO_content];
            [self insertDanmu:[@"管理员：" stringByAppendingString:content]];
        } break;
        case PLVSocketChatRoomEventType_BULLETIN: { // 公告
            NSString *content = chatObject.jsonDict[PLVSocketIOChatRoom_BULLETIN_content];
            [self insertDanmu:[@"公告：" stringByAppendingString:content]];
        } break;
        case PLVSocketChatRoomEventType_SPEAK: {    // 用户发言
            if (user) {  // use不存在时可能为严禁词类型；开启聊天审核后会收到自己数据
                NSString *userId = [NSString stringWithFormat:@"%@",user[PLVSocketIOChatRoomUserUserIdKey]];
                if ([userId isEqualToString:self.login.userId]) {
                    break;
                }
                NSString *speakContent = [chatObject.jsonDict[PLVSocketIOChatRoom_SPEAK_values] firstObject];
                [self insertDanmu:speakContent];
            }
        } break;
        case PLVSocketChatRoomEventType_CLOSEROOM: { // 房间状态
            NSDictionary *value = chatObject.jsonDict[@"value"];
            if ([value[@"closed"] boolValue]) {
                [self insertDanmu:@"系统信息：房间暂时关闭"];
            }else {
                [self insertDanmu:@"系统信息：房间已经打开"];
            }
        } break;
        default: break;
    }
}

- (void)socketIO:(PLVSocketIO *)socketIO connectOnErrorWithInfo:(NSString *)info {
    NSLog(@"socket error: %@",info);
    [self showAlertWithTitle:nil message:@"聊天室出错"];
}

- (void)socketIO:(PLVSocketIO *)socketIO didDisconnectWithInfo:(NSString *)info {
    NSLog(@"socket disconnect: %@",info);
}

- (void)socketIO:(PLVSocketIO *)socketIO reconnectWithInfo:(NSString *)info {
    NSLog(@"socket reconnect: %@",info);
}

#pragma mark - Rewrite

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self clearSocketIO];
    
    [super dismissViewControllerAnimated:flag completion:completion];
}

#pragma mark - Private

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma mark - View Control

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([PLVRtmpSetting sharedRtmpSetting].landscapeMode) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotate {
    return [PLVRtmpSetting sharedRtmpSetting].landscapeMode;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
