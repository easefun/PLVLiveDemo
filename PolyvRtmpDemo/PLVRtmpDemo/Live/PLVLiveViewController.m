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
#import <PLVLiveKit/LFLiveKit.h>
#import <PolyvFoundationSDK/PLVReachability.h>
#import <PolyvFoundationSDK/PLVProgressHUD.h>
#import "PLVLivePreview.h"
#import "PLVRtmpSetting.h"
#import "ZJZDanMu.h"

#if __has_include(<PLVSocketAPI/PLVSocketAPI.h>)
    #import <PLVSocketAPI/PLVSocketAPI.h>
#elif __has_include(<PolyvBusinessSDK/PLVSocketIO.h>)
    #import <PolyvBusinessSDK/PLVSocketIO.h>
#endif

inline static NSString *formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }
    if (bytes <= 0) {
        return @"0 KB/s";
    }
    
    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2fMB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1fKB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ldB/s", (long)bytes_per_sec];
    }
}

@interface PLVLiveViewController () <PLVLivePreviewDelegate, LFLiveSessionDelegate, PLVSocketIODelegate>

@property (nonatomic, strong) PLVLivePreview *livePreview;
@property (nonatomic, strong) ZJZDanMu *danmuLayer;

@property (nonatomic, strong) LFLiveSession *liveSession;
@property (nonatomic, assign) BOOL liveStreaming;

@property (nonatomic, strong) PLVSocketIO *socketIO;
@property (nonatomic, strong) PLVSocketObject *loginSocket;
@property (nonatomic, assign) BOOL loginSuccess;
@property (nonatomic, assign) int reconnectCount;

@property (nonatomic, assign) NSUInteger channelId;

@property (nonatomic, strong) PLVReachability *hostReachability;
//@property (nonatomic, strong) PLVReachability *internetReachability;

@end

@implementation PLVLiveViewController

#pragma mark - Life Cycle

-(void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.liveStreaming = NO;
    self.channelId = [[PLVRtmpSetting sharedRtmpSetting].channelId integerValue];
    
    [self setupLivePreview];
    [self setupDanmuLayer];
    [self connectToSocketServer];
    
    [self configReachAbility];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupLiveSeesion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Private

- (void)showAlertController:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)showLiveErrorAlert:(NSString *)message {
    __weak typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"当前直播已停止" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf restartLive];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showExitConfimAlert:(NSString *)message {
    __weak typeof(self)weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf exitCurrentController];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showHUD:(NSString *)message detailMsg:(NSString *)detailMsg afterDelay:(NSTimeInterval)afterDelay {
    dispatch_async(dispatch_get_main_queue(), ^{
        PLVProgressHUD *hud = [PLVProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = message;
        hud.detailsLabel.text = detailMsg;
        hud.mode = PLVProgressHUDModeText;
        [hud hideAnimated:YES afterDelay:afterDelay];
    });
}

- (void)exitCurrentController {
    [self clearSocket];
    [self clearLiveSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 【PLVLivePreview交互】

- (void)setupLivePreview {
    CGRect viewFrame = self.view.bounds;
    if ([PLVRtmpSetting sharedRtmpSetting].landscapeMode) {
        viewFrame = CGRectMake(0, 0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
    }
    
    self.livePreview = [[PLVLivePreview alloc] initWithFrame:viewFrame];
    self.livePreview.deleagte = self;
    [self.view addSubview:self.livePreview];
}

#pragma mark <PLVLivePreviewDelegate>

- (void)livePreview:(PLVLivePreview *)livePreview didBeautyButtonClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.liveSession.beautyFace = !sender.isSelected;
}

- (void)livePreview:(PLVLivePreview *)livePreview didCameraButtonClicked:(UIButton *)sender {
    AVCaptureDevicePosition devicePositon = self.liveSession.captureDevicePosition;
    self.liveSession.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (void)livePreview:(PLVLivePreview *)livePreview didWaterMarkButtonClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self addWaterMark];
    }else {
        self.liveSession.warterMarkView = nil;
    }
}

- (void)livePreview:(PLVLivePreview *)livePreview didStartLiveButtonClicked:(UIButton *)sender {
    if (self.liveSession.state == LFLivePending) {
        return;
    }
    [self startLive];
}

- (void)livePreview:(PLVLivePreview *)livePreview didCloseButtonClicked:(UIButton *)sender {
    if (self.liveStreaming) {
        [self showExitConfimAlert:@"退出当前直播间？"];
    } else {
        [self exitCurrentController];
    }
}

#pragma mark - 【网络监测】

- (void)configReachAbility {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kPLVReachabilityChangedNotification object:nil];
    
    NSURL *url = [NSURL URLWithString:[PLVRtmpSetting sharedRtmpSetting].rtmpUrl];
    if (url) {
        NSString *remoteHostName = url.host;
        self.hostReachability = [PLVReachability reachabilityWithHostName:remoteHostName];
        [self.hostReachability startNotifier];
    }
}

- (void)reachabilityChanged:(NSNotification *)note {
    PLVReachability* reachability = [note object];
    if ([reachability isKindOfClass:PLVReachability.class]) {
        PLVNetworkStatus netStatus = reachability.currentReachabilityStatus;
        NSLog(@"netStatus：%ld",netStatus);
        if (self.liveStreaming) { // 已开始直播
            if (netStatus == NotReachable) {
                [self.liveSession stopLive];
                [self.livePreview stopState];
                [self showLiveErrorAlert:@"网络连接失败，请稍后重试"];
            } else {
                // 直播结束或错误时才自动重连，避免和 LFLiveSession 重连冲突
                if (self.liveSession.state == LFLiveStop
                    || self.liveSession.state == LFLiveError) {
                    [self restartLive];
                    [self showHUD:@"网络已连接，准备直播" detailMsg:nil afterDelay:3.0];
                }
            }
        }
    }
}

#pragma mark - 【弹幕模块】

- (void)setupDanmuLayer {
    CGRect bounds = self.livePreview.bounds;
    self.danmuLayer = [[ZJZDanMu alloc] initWithFrame:CGRectMake(0, 20, bounds.size.width, bounds.size.height-20)];
    [self.livePreview insertSubview:self.danmuLayer atIndex:0];
}

- (void)insertDanmu:(NSString *)content {
    if (self.danmuLayer && content && content.length) {
        [self.danmuLayer insertDML:content];
    }
}

#pragma mark - 【推流模块】

- (void)setupLiveSeesion {
    self.liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:[PLVRtmpSetting sharedRtmpSetting].audioConfig videoConfiguration:[PLVRtmpSetting sharedRtmpSetting].videoConfig captureType:LFLiveCaptureDefaultMask];
    self.liveSession.captureDevicePosition = AVCaptureDevicePositionBack;   // 开启后置摄像头(默认前置)
    self.liveSession.delegate = self;
    self.liveSession.preView = self.livePreview;
    self.liveSession.showDebugInfo = YES;
    self.liveSession.reconnectCount = 20;
    self.liveSession.reconnectInterval = 3;
    
    [self.liveSession setRunning:YES];
    
    //[self addWaterMark];
    //[self saveLiveToLocal];
}

- (void)clearLiveSession {
    if (self.liveSession) {
        [self.liveSession stopLive];
        self.liveSession = nil;
    }
}

- (void)startLive {
    if (self.liveSession.state == LFLiveStart) {
        return;
    }
    
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
    stream.appVersionInfo = PLVRTMP_SDK_VERSION;
    stream.url = [PLVRtmpSetting sharedRtmpSetting].rtmpUrl;
    
    [self.liveSession startLive:stream];
}

- (void)restartLive {
    [self.liveSession stopLive];
    
    PLVPushChannel *channel = PLVRtmpSetting.sharedRtmpSetting.pushChannel;
    __weak typeof(self)weakSelf = self;
    [PLVLiveAPI getRtmpUrlWithPushChannel:channel completion:^(NSString *rtmpUrl) {
        if (rtmpUrl && [rtmpUrl isKindOfClass:NSString.class]) {
            PLVRtmpSetting.sharedRtmpSetting.rtmpUrl = rtmpUrl;
            [weakSelf startLive];
        }
    }];
}

- (void)addWaterMark {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.alpha = 0.8;
    imageView.frame = CGRectMake(50, 110, 80, 80);
    imageView.image = [UIImage imageNamed:@"pet"];
    
    if (imageView) {
        self.liveSession.warterMarkView = imageView;
    }
}

- (void)saveLiveToLocal {
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    if (movieURL) {
        self.liveSession.saveLocalVideo = YES;
        self.liveSession.saveLocalVideoPath = movieURL;
    }
}

#pragma mark <LFLiveSessionDelegate>

/// live status changed will callback
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSLog(@"%@ %lu", NSStringFromSelector(_cmd),state);
    switch (state) {
        case LFLivePending: {
            self.livePreview.stateLabel.text = @"连接中";
        } break;
        case LFLiveStart: {
            self.liveStreaming = YES;
            self.livePreview.stateLabel.text = @"已连接";
            [self.livePreview liveState];
        } break;
        case LFLiveStop: {
            self.livePreview.stateLabel.text = @"已断开";
            [self.livePreview stopState];
        } break;
        case LFLiveError: {
            self.livePreview.stateLabel.text = @"连接出错";
            [self.livePreview stopState];
        } break;
        case LFLiveRefresh: {
            self.livePreview.stateLabel.text = @"正在刷新";
        } break;
        default: break;
    }
}

/// live debug info callback
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
    NSString *speed  = formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli);
    self.livePreview.rateLabel.text = [NSString stringWithFormat:@"↑%@",speed];
    //NSLog(@"%@ %@ %@", NSStringFromSelector(_cmd),speed,debugInfo);
}

/// callback socket errorcode
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    //NSLog(@"%@ %ld", NSStringFromSelector(_cmd),errorCode);
    [self showLiveErrorAlert:[NSString stringWithFormat:@"当前网络不佳，请稍后再试 #%lu",errorCode]];
}

#pragma mark - 【聊天室模块】

#pragma mark connect/clear

- (void)connectToSocketServer {
    if (self.socketIO) {
        return;
    }
    
    static BOOL loading;
    if (loading) {
        return;
    }
    loading = YES;
    
    NSString *nickName = @"主持人";
    PLVRtmpSetting *setting = [PLVRtmpSetting sharedRtmpSetting];
    if (!setting.isMasterAccount) {
        nickName = setting.channelAccountList[setting.accountId];
    }
    
    self.loginSocket = [PLVSocketObject socketObjectForLoginEventWithRoomId:self.channelId nickName:nickName avatar:nil userType:PLVSocketObjectUserTypeTeacher];
    
    __weak typeof(self)weakSelf = self;
    [PLVLiveAPI getChatTokenWithChannelId:self.channelId role:@"teacher" userId:self.loginSocket.userId appld:setting.appId appSecret:setting.appSecret completion:^(NSDictionary *responseDict, NSError *error) {
        if (error || ![responseDict isKindOfClass:NSDictionary.class]) {
            [weakSelf showAlertController:@"聊天室Token获取失败！" message:error.localizedDescription];
        } else {
            // 初始 socket 对象
            weakSelf.socketIO = [[PLVSocketIO alloc] initSocketIOWithConnectToken:responseDict[@"token"] enableLog:NO];
            weakSelf.socketIO.delegate = weakSelf; // 设置代理接收回调消息
            [weakSelf.socketIO connect];
            //weakSelf.socketIO.debugMode = YES;
        }
        loading = NO;
    }];
}

- (void)clearSocket {
    if (self.socketIO) {
        [self.socketIO disconnect];
        [self.socketIO removeAllHandlers];
        self.socketIO = nil;
    }
}

#pragma mark <PLVSocketIODelegate>

- (void)socketIO:(PLVSocketIO *)socketIO didConnectWithInfo:(NSString *)info {
    NSLog(@"%@--%@",NSStringFromSelector(_cmd),info);
    [socketIO emitMessageWithSocketObject:self.loginSocket];       // 登录聊天室
}

- (void)socketIO:(PLVSocketIO *)socketIO didUserStateChange:(PLVSocketUserState)userState {
    NSLog(@"%s %ld", __FUNCTION__, userState);
}

- (void)socketIO:(PLVSocketIO *)socketIO connectOnErrorWithInfo:(NSString *)info {
    NSLog(@"socket error: %@",info);
    [self showHUD:@"聊天室出错" detailMsg:info afterDelay:3.0];
}

- (void)socketIO:(PLVSocketIO *)socketIO didDisconnectWithInfo:(NSString *)info {
    NSLog(@"socket disconnect: %@",info);
}

- (void)socketIO:(PLVSocketIO *)socketIO reconnectWithInfo:(NSString *)info {
    NSLog(@"socket reconnect: %@",info);
}

/// 公聊消息
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
                if ([userId isEqualToString:self.loginSocket.userId]) {
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

@end
