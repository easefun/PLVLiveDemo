# PolyvStreamerDemo

本工程是演示如何利用polyv的sdk进行视频推流，以及PLVSession的部分使用说明（更新中）

ployv视频推流sdk的使用事项：

1.在工程中导入PLVSession文件夹及其中的子项，libPolyvStreamer.a是推流的静态库文件

2.另外需要使用libc++.tbd 和 VideoToolbox.framework框架
     具体步骤：工程project-targets-Build Phases-Link binary with Libraries中导入以上两个库和框架
  
3.iOS9之后需要在Info.plist中添加Dictionary类型的App Transport Security Settings条目
     并在该条目下添加Boolean类型的Allow Arbitrary Loads条目，值为YES
