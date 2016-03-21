# PolyvStreamerDemo

本工程是演示如何利用polyv的sdk进行视频推流，以及PLVSession的部分使用说明

ployv视频推流sdk使用事项：

1.在工程中导入PLVSession文件夹及其中的子项，libPolyvStreamer.a是推流的静态库文件(可用于真机和模拟机测试)

2.另外需要使用libc++.tbd 和 VideoToolbox.framework
     具体步骤：工程project-targets-Build Phases-Link binary with Libraries中导入以上两个库
  
3.iOS9之后需要在Info.plist中添加Dictionary类型的App Transport Security Settings条目
     并在该条目下添加Boolean类型的Allow Arbitrary Loads条目，值为YES（亦可使用其他方式，具体操作可参考网上关于App Transport      Security教程）参考链接：https://developer.apple.com/library/prerelease/ios/releasenotes/General/WhatsNewIniOS/Articles/iOS9.html

# PLVSession 类的使用（具体可参考demo工程中的代码实现）

1.初始化一个session对象

_session = [[PLVSession alloc] initWithVideoSize:CGSizeMake(1280, 720) frameRate:25 bitrate:600*1024 useInterfaceOrientation:YES];

2.设置session属性previewView的frame值，添加到父视图上
     _session.previewView.frame = self.previewView.bounds;
    [self.view addSubview:_session.previewView];
    
3.设置代理人
     _session.delegate = self;

需要代理人实现connectionStatusChanged：方法
