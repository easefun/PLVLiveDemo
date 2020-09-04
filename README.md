# PLVRtmpDemo

[![build passing](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)
[![GitHub release](https://img.shields.io/badge/release-v2.2.4-blue.svg)](https://github.com/easefun/PLVLiveDemo/releases/tag/v2.3.0)

本项目从属于广州易方信息科技股份有限公司旗下的POLYV保利威视频云核心产品“云直播”，展示了如何使用保利威 PLVLiveKit、PolyvLiveAPI、PolyvBusinessSDK 这三个 SDK 实现视频直播、聊天室功能。想要集成本项目提供的 SDK 或使用本 demo，需要在[保利威视频云平台](http://www.polyv.net/)注册账号，并开通相关服务。

本项目包含如下功能：选择推流清晰度、选择横竖屏推流、支持美颜、支持切换前后置摄像头。

### 1 试用

[点击安装内测版](https://www.pgyer.com/Tmmv)，或扫描下方二维码使用 Safari 安装，安装密码：polyv。

![GitHub set up-w140](https://static.pgyer.com/app/qrcode/Tmmv)

也可通过 AppStore 安装正式版：[Polyv 云直播](https://apps.apple.com/cn/app/polyv-%E4%BA%91%E7%9B%B4%E6%92%AD/id1178906547)。

### 2 运行环境

本文档为技术文档，需要阅读者具备基本的 iOS 开发能力，且需要配置苹果的开发环境。

- Mac OS 10.10+
- Xcode 9.0+
- CocoaPods 1.7.0+

### 3 安装运行

1. 下载当前项目至本地
2. 进入 PolyvRtmpDemo 目录，执行 `pod install` 或 `pod update`
3. 打开生成的 `.xcworkspace` 文件，编译、运行即可

### 4 项目结构

```
├── PLVRtmpDemo
│   ├── AppDelegate
│   ├── Library
│   ├── category
│   ├── Main // 首页/登录页
│   │   ├── Base.lproj
│   │   │   └── Main.storyboard
│   │   ├── LoginViewController
│   │   ├── PLVNavigationController
│   ├── Live  // 直播页
│   │   ├── PLVLivePreview
│   │   ├── PLVLiveViewController
│   ├── Setting // 设置页
│   │   ├── PLVRtmpSetting
│   │   ├── PLVSettingViewController
│   └── Supporting Files
├── Podfile  // 依赖库配置文件
├── Podfile.lock
├── Pods     // 依赖库
├── PLVRtmpDemo.xcodeproj
└── PLVRtmpDemo.xcworkspace
```

### 5 依赖库

使用 CocoaPods 将各个依赖库集成到项目中。首先，在项目中新建一个 Podfile 文件，添加以下内容（2.3.0之前版本）

```ruby
#source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "8.0"

#这一行必须要添加
use_frameworks!

target 'PLVRtmpDemo' do
    pod 'PLVLiveKit', '~> 1.2.4'
    pod 'PolyvLiveAPI', '~> 0.7.4'
    pod 'PolyvSocketAPI', '~> 0.6.1'
    pod 'PolyvFoundationSDK', '~> 0.10.1'
    
    # 如果同时集成云课堂SDK，则移除PolyvSocketAPI、PolyvFoundationSDK，使用云课堂SDK即可（最低0.13版本）
    #pod 'PolyvCloudClassSDK', '~> 0.13'
    
    # Xcode 10 以下解注释
    #pod 'Starscream', '3.0.5'
end
```

或以下方式（2.3.0 版本及以上）


```ruby
platform :ios, "8.0"

use_frameworks!

target 'PLVRtmpDemo' do
  pod 'PLVLiveKit', '~> 1.2.4'
  pod 'PolyvLiveAPI', '~> 0.8.1'
  pod 'PolyvBusinessSDK', '~> 0.15.0'
end
```

然后，执行 `pod install` 或 `pod update` 命令。

**暂未提供非 pod 下载方式集成**

`PolyvLiveAPI` [项目地址](https://github.com/polyv/PolyvLiveAPI)

`PolyvSocketAPI` [项目地址](https://github.com/polyv/PolyvSocketAPI)

### 6 项目配置

#### 6.1 添加权限

本项目需要使用到设备的麦克风和摄像头，需要在项目的 info.plist 中配置以下 key 值：

- Privacy - Microphone Usage Description
- Privacy - Camera Usage Description

#### 6.2 支持横竖屏

本项目支持横竖屏播放，选择 Targets 的 General 菜单栏，在 Deployment Info 中的 Device Orientation 进行设置。

### 7 代码示例

详细直播模块可以参考 PLVLiveViewController 类文件

```
#PLVLiveViewController 文件结构

#pragma mark - Life Cycle
#pragma mark - View Control
#pragma mark - Private
#pragma mark - 【PLVLivePreview交互】
#pragma mark - 【网络监测】
#pragma mark - 【弹幕模块】
#pragma mark - 【推流模块】
#pragma mark - 【聊天室模块】
```

#### 7.1 直播推流

```objective-c
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupLiveSeesion];
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
```

#### 7.2 聊天室

```objective-c
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
```

#### 7.3 弹幕

```objective-c
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
```

### 8 FAQ（常见问题）

#### 8.1 编译时控制台输出 “image not found”

基本为 SocketIO swift 库加载问题，如您的项目中为自动配置 Swift 版本，可尝试手动配置，Targets -> Build Settings -> User-Defined 添加 SWIFT_VERSION 字段，设置值为 4.2。

#### 8.2 Socket.io 冲突问题

出现 `Socket.IO-Client-Swift` 库冲突时可以以下方式解决，将 pod 'PolyvSocketAPI' 更新为 pod 'PolyvSocketAPI/Core'（PolyvSocketAPI的子依赖库Core不含Socket.IO-Client-Swift依赖）

如 `pod 'PolyvSocketAPI', '~> 0.6.1'` 等同

```ruby
pod 'PolyvSocketAPI/Core', '~> 0.6.1'
pod 'Socket.IO-Client-Swift', '~> 14.0.0'
```

或 `pod 'PolyvBusinessSDK', '~> 0.15.0'` 等同

```ruby
pod 'PolyvBusinessSDK/Core', '~> 0.6.1'
pod 'Socket.IO-Client-Swift', '~> 14.0.0'
```

