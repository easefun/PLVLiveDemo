# PLVRtmpDemo

### 版本信息

最新版本：v2.2.x

版本历史：[Releases](https://github.com/easefun/PLVLiveDemo/releases)

   

### 运行环境

1. Mac OS 10.10+
2. Xcode 9.0+
3. CocoaPods



### 安装运行

1. 下载当前项目至本地
2. 进入 PolyvRtmpDemo 目录，执行 `pod install` 或 `pod update`
3. 打开生成的 `.xcworkspace` 文件，编译、运行即可



[手机安装](https://www.pgyer.com/Tmmv) （需使用 POLYV 直播账号登录使用）

![GitHub set up-w140](https://static.pgyer.com/app/qrcode/Tmmv)

Polyv 云直播 App [App Store](https://apps.apple.com/cn/app/polyv-%E4%BA%91%E7%9B%B4%E6%92%AD/id1178906547)



### 项目结构

```
├── PLVRtmpDemo
│   ├── AppDelegate
│   ├── Library
│   ├── Live  // 直播页
│   │   ├── PLVLivePreview
│   │   ├── PLVLiveViewController
│   ├── Main // 首页/登录页
│   │   ├── Base.lproj
│   │   │   └── Main.storyboard
│   │   ├── LoginViewController
│   │   ├── PLVNavigationController
│   ├── Setting // 设置页
│   │   ├── PLVRtmpSetting
│   │   ├── PLVSettingViewController
│   ├── Supporting\ Files
│   └── category
├── PLVRtmpDemo.xcodeproj
├── Podfile  // 依赖库配置文件
```



### 依赖库

podfile 中需要添加 `use_frameworks!`

```ruby
#source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "8.0"

use_frameworks!

target 'PLVRtmpDemo' do
    pod 'PLVLiveKit', '~> 1.2.4'
    pod 'PolyvLiveAPI', '~> 0.7.3'
    pod 'PolyvSocketAPI', '~> 0.6.1'
    pod 'PolyvFoundationSDK', '~> 0.10.1'
    
    # 如果同时集成云课堂SDK，则移除PolyvSocketAPI、PolyvFoundationSDK，使用云课堂SDK即可（最低0.13版本）
    #pod 'PolyvCloudClassSDK', '~> 0.13'
    
    # Xcode 10 以下解注释
    #pod 'Starscream', '3.0.5'
end
```

直播API接口 [PolyvLiveAPI](https://github.com/polyv/PolyvLiveAPI)

Socket API 接口 [PolyvSocketAPI](https://github.com/polyv/PolyvSocketAPI)

**暂未提供非 pod 下载方式集成**



### 项目配置

1. 隐私权限配置

   需要在项目的 info.plist 中配置以下 key 值

   `Privacy - Microphone Usage Description`

   `Privacy - Camera Usage Description`

2. 横竖屏支持

   项目配置中需要支持横竖屏模式



### 代码示例

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



1. 直播推流

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

2. 聊天室

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

3. 弹幕

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
   
   

### FAQ（常见问题）

1. 编译时控制台输出 “image not found”

   基本为 SocketIO swift 库加载问题，如您的项目中为自动配置 Swift 版本，可尝试手动配置，target -> build settings -> Add User-Defined Setting 添加一个 SWIFT_VERSION 字段，设置值为 4.2