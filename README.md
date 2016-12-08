# PLVLiveDemo

> 本工程为POLYV直播推流v2版本，v1版本基于videocore开发，若使用videocore版本的SDK可移步本项目的[develop_videocore](https://github.com/easefun/PLVLiveDemo/tree/develop_videocore)分支。

本工程为完整的DEMO，下载后可以直接编译运行，若将SDK文件添加至自工程中可参考下文的说明。文档末附带已打包的app可供下载使用。 

建议支持最低系统版本iOS 8.0，且苹果在iOS 8.0后才开始支持硬编码。

## 推流特性

- 后台录制
- 支持横竖屏录制
- 支持基于GPUImage的美颜
- 支持H264 AAC硬编码
- 弱网环境丢帧
- 动态码率切换
- 配置音频
- 配置视频
- RTMP传输
- 切换摄像头位置
- 音频静音
- 支持发送buffer
- 支持水印
- 支持单一视频或音频
- 支持外部输入输出设备

*参考说明[LFLiveKit](https://github.com/LaiFengiOS/LFLiveKit/blob/master/README.md)*

## 组件资源

PLVLiveDemo 下载内容包括 PolyvLiveSDK（POLYV推流SDK） 和 LiveDemo 两部分：

- PolyvLiveSDK  目录（存放推流库及POLYV的接口）
 - LMGPUImage ---- 基于著名开源项目GPUImage的二次开发，具有丰富的滤镜可供使用
 - pili-librtmp ---- 开源的iOS客户端RTMP库
 - LFLiveKit ---- 开源直播推流库，完成主要的推流任务（LMGPUImage、pili-librtmp在这个库中使用）
 - PolyvLiveAPI.framework ---- 提供POLYV的登录接口等

- LiveDemo 目录（提供在iOS上使用PolyvLiveSDK进行推流的演示）
 - LoginViewController ---- POLYV登录控制器
 - SettingViewController ---- 配置推流参数的控制器
 - PLVLiveViewController ---- 推流控制器
 - PLVLivePreview ---- 推流预览及推流逻辑处理

## 工程配置

1. 先将PolyvLiveSDK文件拷贝至自己的项目文件中并添加至工程项目中
2. 使用到的库文件
   - AudioToolbox.framework
   - VideoToolbox.framework
   - AVFoundation.framework
   - Foundation.framework
   - UIKit.framework
   - libz.tbd
   - libstdc++.tbd
   
   选择项目target->Build Phases->Link Binary With Libraries，点击下方+号，添加以上的库文件
3. ATS(App Transport Security)

    *苹果要求从2017年1月1日起App Store中的所有应用都必须启用 App Transport Security（ATS）安全功能。ATS是苹果在iOS 9中引入的一项隐私保护功能，屏蔽明文HTTP资源加载，连接必须经过更安全的HTTPS。*
    
    在没有这项规定之前（或暂未考虑上架App Store）在iOS 9.0版本后通用的做法可以是屏蔽ATS功能，具体操作如下：
    右键点击项目的plist文件->Open As Source Code 添加以下内容：
    
```  <key>NSAppTransportSecurity</key>
  <dict>
      <key>NSAllowsArbitraryLoads</key>
      <true/>
  </dict>
```
在要求必须启用ATS功能后如使用非https的链接则可在info.plist中配置白名单域名，添加以下内容：

```
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSExceptionDomains</key>
		<dict>
			<key>sdkoptedge.chinanetcenter.com</key>
			<dict>
				<key>NSIncludesSubdomains</key>
				<false/>
				<key>NSExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
			</dict>
		</dict>
	</dict>
```
其他使用到的http链接可参考以上方式添加。

## PolyvLiveSDK使用说明

1. 获取RTMP推流地址
    
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

2. 设置推流预览视图
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
3. 初始化session，配置音视频参数
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

4. 通知服务器推流模式为单流模式

   如该频道之前推流过PPt和视频双流，此时需要主动通知服务器切回单视频流模式
    ```objective-c
    [PolyvLiveLogin configAloneStreamModeWithChannelId:[PLVChannel sharedPLVChannel].channelId stream:[PLVChannel sharedPLVChannel].streamName success:^(NSString *responseBody) {
            self.aloneMode = YES;
        } failure:^(NSString *failure) {
            NSLog(@"config alone steam mode failed:%@",failure);
    }];
    ```

5. 代理方法

    ```objective-c
    // 推流状态改变的回调
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state;
// 调试信息的回调（可获取上传速率、发送帧数等参数信息）
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo;
// socket连接出错的回调
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode;
    ```

6. 其他功能
 
 **设置水印功能**
 
```objective-c
UIImageView *imageView = [[UIImageView alloc] init];
imageView.alpha = 0.8;
imageView.frame = CGRectMake(50, 110, 80, 80);
imageView.image = [UIImage imageNamed:@"pet"];
_session.warterMarkView = imageView;
```

**本DEMO中用到第三方开源推流库在源代码上有修改，不建议直接使用源库，且同样保持开源。**



附：扫码下载APP

-------

DEMO[下载地址](https://www.pgyer.com/VN0u)，iPhone手机直接安装（需要POLYV的直播账号登录使用）

![GitHub set up-w140](https://static.pgyer.com/app/qrcode/VN0u)


