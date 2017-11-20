# PLVLiveDemo

> 本项目为 POLYV 直播推流 SDK v2 版本。v1版基于 videocore 开发，若使用 videocore 版本 SDK 可移步本项目的 [develop_videocore](https://github.com/easefun/PLVLiveDemo/tree/develop_videocore) 分支。

## 最近更新

- 优化代码，解决在iOS11下导致手机重启问题。更新推流参数，推流参数使用25帧率，15帧率测试在iOS11下可能存在问题
- `SocketIO.framework` 库默认使用 cocopod 添加。`SocketIO` 当前版本为 `12.0` ，支持Xcode 9.0 编译环境。

## （一）下载须知

- 建议支持最低系统版本：iOS 8.0
- 本项目下载后可以直接编译运行；添加 SDK 文件至其他项目可参考以下文档说明
- `SocketIO` 库的更新较为频繁，升级 Xcode 后编译或运行出错可查询是否存在新版本或可用版本。链接：https://cocoapods.org/?q=Socket.IO-Client-Swift

## （二）推流 SDK 特性

- 支持横屏、竖屏录制
- 支持基于GPUImage的美颜
- 支持H264 AAC硬编码
- 弱网环境丢帧
- 动态码率切换
- 配置音频
- 配置视频
- RTMP传输
- 切换前后摄像头
- 音频静音
- 支持发送buffer
- 支持水印
- 支持单一视频或音频
- 支持外部输入输出设备

*参考说明[LFLiveKit](https://github.com/LaiFengiOS/LFLiveKit/blob/master/README.md)*

## （三）文件结构和功能介绍

PLVLiveDemo 包括 PolyvLiveSDK （POLYV 推流 SDK ）和 LiveDemo 两部分：

- PolyvLiveSDK  目录（存放推流库及POLYV的接口）

  - LMGPUImage ---- 基于开源项目 GPUImage 的二次开发，具有丰富的滤镜可供使用
  - pili-librtmp ---- 开源的 iOS 客户端 RTMP 库
  - LFLiveKit ---- 开源直播推流库，完成主要的推流任务（LMGPUImage、pili-librtmp在这个库中使用）
  - ZJZDanMu ---- 弹幕库
  - PLVChatManager.framework ---- POLYV 聊天室相关接口的封装
  - PLVStreamerAPI.framework ---- 提供 POLYV 登录推流相关接口
  - ~~PolyvLiveAPI.framework~~(废弃) ---- 更新使用 `PLVChatManager.framework`
  - ~~SocketIO.framework~~(废弃) ---- SocketIO Swift版本库，用于连接POLYV聊天室进行通讯

- LiveDemo 目录（demo 部分）

  - LoginViewController ---- 登录页
  - SettingViewController ---- 参数配置页
  - PLVLiveViewController ---- 推流页

## （四）使用配置

1. PolyvLiveSDK 文件拷贝至自己的项目中，添加 `PLVChatManager.framework`、`PLVStreamerAPI.framework` 库文件至工程的"Linked Frameworks and Libraries"中
  
2. 使用到的系统库文件

   - AudioToolbox.framework
   - VideoToolbox.framework
   - AVFoundation.framework
   - Foundation.framework
   - UIKit.framework
   - libz.tbd
   - libstdc++.tbd
   
   选择项目target->Build Phases->Link Binary With Libraries，点击下方+号，添加以上的库文件

## （五）PolyvLiveSDK 代码示例

5.1 初始化直播推流、聊天室、弹幕

 ```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initLivePreview];     // 初始化直播界面及推流器
    [self initChatRoom];        // 添加聊天室
    [self configDanmu];         // 初始化弹幕
}

- (void)initLivePreview {
    CGRect viewFrame;
    if (self.supportedInterfaceOrientation==UIInterfaceOrientationPortrait) {
        viewFrame = self.view.bounds;
    }else {
        viewFrame = CGRectMake(0, 0, HEIGHT, WIDTH);
    }
    
    self.livePreview = [[PLVLivePreview alloc] initWithFrame:viewFrame];
    self.livePreview.supportedInterfaceOrientation = self.supportedInterfaceOrientation;
    //livePreview.audioQuality = self.audioQuality;
    self.livePreview.videoQuality = self.videoQuality;
    
    [self.view addSubview:self.livePreview];
}

-(void)initChatRoom {
    [PLVChatRequest getChatTokenSuccess:^(NSString *chatToken) {
        NSLog(@"chat token is %@", chatToken);
        @try {
            _chatSocket = [[PLVChatSocket alloc] initChatSocketWithConnectParams:@{@"token":chatToken} enableLog:NO];
            _chatSocket.delegate = self;
            [_chatSocket connect];
        } @catch (NSException *exception) {
            NSLog(@"chat connect failed, reason:%@",exception.reason);
        }
    } failure:^(NSString *errorName, NSString *errorDescription) {
        NSLog(@"errorName: %@, errorDescription: %@",errorName,errorDescription);
    }];
}

- (void)configDanmu {
    CGRect bounds = self.livePreview.bounds;
    self.danmuLayer = [[ZJZDanMu alloc] initWithFrame:CGRectMake(0, 20, bounds.size.width, bounds.size.height-20)];
    [self.livePreview insertSubview:self.danmuLayer atIndex:0];
}

 ```

5.2 获取RTMP推流地址
    
 导入头文件`#import <PolyvLiveAPI/PolyvLiveAPI.h>` 使用以下接口
 
    ```objective-c
    /**
     *  使用保利威视直播接口获取推流的相关信息
     *
     *  @param channelId 登录直播的频道号或子频道号
     *  @param password  登录直播频道号的密码
     *  @param success   登录成功的回调信息（推流地址和流名）
     *  @param failure   登录失败的回调信息（如频道账号密码错误、网络请求失败等）
     */
    + (void)loginWithChannelId:(NSString *)channelId
                      password:(NSString *)password
                       success:(void(^)(NSString *rtmpUrl, NSString *streamName))success
                       failure:(void(^)(NSString *errName, NSString *errReason))failure;
    ```
具体如下：

    ```objective-c
   __weak typeof(self)weakSelf = self;
   [PolyvLiveLogin loginWithChannelId:self.channelIdTF.text password:self.passwordTF.text success:^(NSString *rtmpUrl, NSString *streamName) {
    
       SettingViewController *settingVC = [SettingViewController new];
       settingVC.rtmpUrl = [NSString stringWithFormat:@"%@%@",rtmpUrl,streamName];
       
       dispatch_async(dispatch_get_main_queue(), ^{
           [weakSelf.navigationController pushViewController:settingVC animated:YES];
           //[self presentViewController:settingVC animated:YES completion:nil];
       });
   } failure:^(NSString *errName, NSString *errReason) {
       NSLog(@"login: errTitle:%@,errReason:%@",errName,errReason);
       
       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:errName message:errReason preferredStyle:UIAlertControllerStyleAlert];
       [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
       dispatch_async(dispatch_get_main_queue(), ^{
           [weakSelf presentViewController:alertController animated:YES completion:nil];
       });
   }];
    
    ```

5.3 设置推流预览视图
此时需要特别注意的是横竖屏的不同frame，示例如下：

    ```objective-c
    CGRect viewFrame;
    if (self.supportedInterfaceOrientation==UIInterfaceOrientationPortrait) {
        viewFrame = self.view.bounds;
    }else {
        viewFrame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
    }
    
    PLVLivePreview *livePreview = [[PLVLivePreview alloc] initWithFrame:viewFrame];
    livePreview.rtmpUrl = self.rtmpUrl;
    livePreview.supportedInterfaceOrientation = self.supportedInterfaceOrientation;
    //livePreview.audioQuality = self.audioQuality;
    livePreview.videoQuality = self.videoQuality;
    
    [self.view addSubview:livePreview];
    ```
5.4 初始化session，配置音视频参数
   导入`LFLiveKit.h`头文件
 
 即可使用默认的音视频配置也可以自定义配置，示例配置一个视频分辨率540x960、帧率20、视频码率800x1024、音频采样率44.1KHz、音频码率96Kbps的直播session，如下：
 
    ```objective-c
    LFLiveVideoConfiguration *videoConfig = [LFLiveVideoConfiguration new];
    videoConfig.videoSize = (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait)?CGSizeMake(540, 960):CGSizeMake(960, 540);
    videoConfig.videoFrameRate = 20;
    videoConfig.videoBitRate = 800*1024;
    videoConfig.videoMaxBitRate = 1100*1024;
    videoConfig.videoMinBitRate = 500*1024;                 
    videoConfig.videoMaxKeyframeInterval = 40;
    videoConfig.sessionPreset = LFCaptureSessionPreset540x960;
    videoConfig.autorotate = YES;
    videoConfig.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
    LFLiveAudioConfiguration *audioConfig = [LFLiveAudioConfiguration new];
    audioConfig.numberOfChannels = 2;   // 声道数
    audioConfig.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
    audioConfig.audioBitrate = LFLiveAudioBitRate_96Kbps;
           
    _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfig videoConfiguration:videoConfig captureType:LFLiveCaptureDefaultMask];
    _session.captureDevicePosition = AVCaptureDevicePositionBack;   // 开启后置摄像头(默认前置)
    ```

 设置代理 `_session.delegate = self;`
 是否输出调试信息`_session.showDebugInfo = YES;` 
 设置视频的预览视图`_session.preView = self;`

5.5 通知服务器推流模式为单流模式

   如该频道之前推流过PPt和视频双流，此时需要主动通知服务器切回单视频流模式
    ```objective-c
    [PolyvLiveLogin configAloneStreamModeWithChannelId:[PLVChannel sharedPLVChannel].channelId stream:[PLVChannel sharedPLVChannel].streamName success:^(NSString *responseBody) {
            self.aloneMode = YES;
        } failure:^(NSString *failure) {
            NSLog(@"config alone steam mode failed:%@",failure);
    }];
    ```

5.6 代理方法

    ```objective-c
    // 推流状态改变的回调
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state;
// 调试信息的回调（可获取上传速率、发送帧数等参数信息）
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo;
// socket连接出错的回调
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode;
    ```

5.7 其他功能
 
 **设置水印功能**
 
```objective-c
UIImageView *imageView = [[UIImageView alloc] init];
imageView.alpha = 0.8;
imageView.frame = CGRectMake(50, 110, 80, 80);
imageView.image = [UIImage imageNamed:@"pet"];
_session.warterMarkView = imageView;
```

**SDK 中部分第三方库有修改优化，不建议直接使用源库。**

## （六）FAQ

1. `SocketIO.framework` 库库问题
    查看 `SocketIO` 库是否存在更新或可用版本，[Socket.IO-Client-Swift](https://cocoapods.org/?q=Socket.IO-Client-Swift)

Podfile 中添加形式如下：

    ```
    use_frameworks!

    target 'YourApp' do
        pod 'Socket.IO-Client-Swift', 12.0
        # pod 'Socket.IO-Client-Swift', '~> 8.2.0'
    end
    ```

2. 网络访问问题
    
    因 HTTP 网络访问问题可尝试以下解决方案：
    
    在工程 info.plist 中添加 `NSAppTransportSecurity` 属性，并设置 `<key>NSAllowsArbitraryLoads</key><true/>` 键值。


附：扫码下载（和本工程源代码不同步）

-------

DEMO [下载地址](https://www.pgyer.com/VN0u)，iPhone 手机直接安装（需要 POLYV 直播账号登录使用）

![GitHub set up-w140](https://static.pgyer.com/app/qrcode/VN0u)


