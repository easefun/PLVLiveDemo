# PLVRtmpDemo

### 最近更新 

最新版本：v2.2.1

1. 优化首次进入直播页卡顿问题

    `pod 'PLVLiveKit', '~> 1.2.3'`

   

### 运行环境

1. Mac OS 10.10+（建议）
2. Xcode 9.0+
3. CocoaPods



### 安装运行

1. 下载当前项目至本地
2. 进入 PolyvRtmpDemo 目录，执行 `pod install` 或 `pod update`（如果 pod install 执行失败）
3. 打开生成的 `.xcworkspace` 文件，编译、运行即可



[手机安装](https://www.pgyer.com/VN0u) （需使用 POLYV 直播账号登录使用）

![GitHub set up-w140](https://static.pgyer.com/app/qrcode/VN0u)



### 项目结构

```
├── PLVRtmpDemo
│   ├── AppDelegate.h
│   ├── AppDelegate.m
│   ├── Library
│   ├── Live  // 直播页
│   │   ├── PLVLivePreview.h // 
│   │   ├── PLVLivePreview.m
│   │   ├── PLVLiveViewController.h
│   │   └── PLVLiveViewController.m
│   ├── Main // 首页/登录页
│   │   ├── Base.lproj
│   │   │   └── Main.storyboard
│   │   ├── LoginViewController.h
│   │   ├── LoginViewController.m
│   │   ├── PLVNavigationController.h
│   │   └── PLVNavigationController.m
│   ├── Setting // 设置页
│   │   ├── PLVRtmpSetting.h
│   │   ├── PLVRtmpSetting.m
│   │   ├── PLVSettingViewController.h
│   │   └── PLVSettingViewController.m
│   ├── Supporting\ Files
│   └── category
├── PLVRtmpDemo.xcodeproj
├── Podfile  // 依赖库配置文件
```



### 依赖库

podfile 中需要添加 `use_frameworks!`

```ruby
platform :ios, "8.0"

use_frameworks! 

target 'PLVRtmpDemo' do
    pod 'MBProgressHUD', '~> 1.1.0'
    
    pod 'PLVLiveKit', '~> 1.2.2'        # polyv streamer.
    pod 'PolyvLiveAPI', '~> 0.7.1'      # Polyv live api.
    pod 'PolyvSocketAPI', '~> 0.6.1'    # Polyv socket.io api.
    #pod 'Starscream', '3.0.5'           # Xcode 10 以下解注释
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

1. 直播推流

   详细配置可以参考 PLVLivePreview 类文件

   ```objective-c
   - (void)setupUI {
       CGRect viewFrame = self.view.bounds;
       if ([PLVRtmpSetting sharedRtmpSetting].landscapeMode) {
           viewFrame = CGRectMake(0, 0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth([UIScreen mainScreen].bounds));
       }
       self.livePreview = [[PLVLivePreview alloc] initWithFrame:viewFrame];
       [self.view addSubview:self.livePreview];
   }
   
   - (void)viewWillAppear:(BOOL)animated {
       [super viewWillAppear:animated];
   
       [self.livePreview setupSeesion];
   }
   ```

2. SocketIO

   ```objective-c
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
   ```

3. 弹幕

   ```objective-c
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
   ```

   

### FAQ（常见问题）

1. 编译时控制台输出 “image not found”

   基本为 SocketIO swift 库加载问题，如您的项目中为自动配置 Swift 版本，可尝试手动配置，target -> build settings -> Add User-Defined Setting 添加一个 SWIFT_VERSION 字段，设置值为 4.2