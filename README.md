# PolyvStreamerDemo

> PolyvStreamerDemo使用的PolyvStreamerSDK基于videoCore，进行了二次封装，提供了丰富的接口可供设置。直播推流服务器为国内一流、稳定的网宿服务。网页端观看直播地址http://live.polyv.net/watch/'频道号'.htm 

推流SDK的完整下载包中包含 PolyvStreamerSDK 和 PolyvStreamer 两部分。PolyvStreamerSDK中存放推流 SDK 的 API 头文件 PLVSession.h 和静态库（arm/x86），库文件详情如下所示：

- arm文件夹下的静态库适用于真机, 支持armv7 arm64(工程默认添加此文件夹下的静态库)
- x86_64文件夹下的静态库适用于模拟器, 支持 i386 x86_64
![](https://github.com/easefun/PolyvStreamerDemo/blob/master/images/01%402x.png)

## 准备开发环境
1.	导入SDK中的libPolyvStreamer.a静态库

	根据不同的开发环境选择使用x86_64目录下或arm目录下的库文件，使用sdk首先需要将静态库存储在项目工程中，可以直接将此库文件拖入工程。注意要选择"copy items if needed"，此时会在"Library Search Paths"中自动添加库的搜索路径

2. 导入libc++.tbd 和 VideoToolbox.framework依赖库
 	
 	工程project-targets-Build Phases-Link binary with Libraries下查找并添加以上两个库
	
	![](https://github.com/easefun/PolyvStreamerDemo/blob/master/images/02%402x.png)
	
3. 设置"other link flags"标记为 -ObjC
	 在project->TARGETS->Build Settings的Other Linker Flags条目中双击空白处添加 -Objc
	 
4. 配置允许非https网络内容访问
	iOS9.0后要求App访问的网络必须使用HTTPS协议，为了解决这个问题。我们可以在Info.plist文件中添加NSAppTransportSecurity条目，此条目下再添加NSAllowsArbitraryLoads，并设值为YES 
			
		参考链接：https://developer.apple.com/library/prerelease/ios/releasenotes/General/WhatsNewIniOS/Articles/iOS9.html


## PLVSession.h 接口说明

1. 初始化session对象
```objective-c
    _session = [[PLVSession alloc] initWithVideoSize:CGSizeMake(1280, 720) frameRate:25 bitrate:600*1024 useInterfaceOrientation:YES];
```
2. 设置session属性previewView的frame值，添加到父视图上
```objective-c
     _session.previewView.frame = self.previewView.bounds;
    [self.view addSubview:_session.previewView];
```
3. 设置代理人`_session.delegate = self;`

	代理人需要实`connectionStatusChanged：`方法

4.	停止推流

	将session的代理置空，再结束推流
```objective-c
       _session.delegate = nil;
       [_session endRtmpSession];
```

### 注意问题

- 在切换使用模拟器和真机静态库时编译错误，提示x86_64或者 armv7 arm64库文件未找到，需要注意可能工程依旧引用之前的库文件

	解决方案：将之前静态库放到其他目录下或将模拟器下和真机下的两个版本的静态库合并为一个版本。在终端下使用lipo -create - output命令，”lipo -create ’真机版本路径‘ ’模拟器版本路径‘ -output ’合并后的文件路径‘“
	![](https://github.com/easefun/PolyvStreamerDemo/blob/master/images/03%402x.png)
	
- 如果在iOS8中遇到崩溃问题 `Terminating app due to uncaught exception 'NSUnknownKeyException', reason: '[ setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key layoutMarginsFollowReadableWidth.'` 是demo工程中使用size class的屏幕适配问题，可参考http://stackoverflow.com/questions/34906745/layoutmarginsfollowreadablewidth-error-in-ios-8/37205228#37205228

> 如有其他问题、意见或者建议，欢迎通过github、邮箱(fanfengtao@polyv.net)、qq等方式提出。

### 版本更新

2016.6.24

- 添加登录界面
- 推流服务器地址改为从接口中获取
- 重新打包生成静态库,添加支持armv7
- 重构工程，优化代码逻辑，删除冗余的代码，降低代码耦合度
