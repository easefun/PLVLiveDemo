/*

 Video Core
 Copyright (c) 2016 polyv http://www.polyv.net

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

 */

/*!
 *  A PLV Objective-C Session API that will create an RTMP session using the
 *  device's camera(s) and microphone.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@class PLVSession;

/* 推流sdk运行过程中的状态
 */
typedef NS_ENUM(NSInteger, PLVSessionState)
{
    PLVSessionStateNone = 0,        // 推流sdk的初始状态
    PLVSessionStatePreviewStarted,  // 开始出现预览画面
    PLVSessionStateStarting,        // 正在连接服务器或创建码流传输通道
    PLVSessionStateStarted,         // 已经建立连接
    PLVSessionStateEnded,           // 推流已经结束
    PLVSessionStateError            // 推流sdk运行过程中出错
};

/* 摄像头类型
 */
typedef NS_ENUM(NSInteger, PLVCameraState)
{
    PLVCameraStateFront = 0,        // 前置摄像头
    PLVCameraStateBack              // 后置摄像头
};

/* 视频画面的填充方式
 */
typedef NS_ENUM(NSInteger, PLVAspectMode)
{
    PLVAspectModeFit = 0,       // 画面保持比例，但是高宽自适应视频窗口
    PLVAspectModeFill          // 画面拉伸填满视频窗口
};

/* 实时滤镜类型 With new filters should add an enum here
 */
typedef NS_ENUM(NSInteger, PLVFilter) {
    PLVFilterNormal = 0,        // 正常颜色
    PLVFilterGray,              // 灰度处理滤镜
    PLVFilterInvertColors,      // 反色处理滤镜
    PLVFilterSepia              // 棕色滤镜
};

@protocol PLVSessionDelegate <NSObject>

@required
// 推流sdk状态发生改变时，该接口会被调用，参数sessionState为当前推流sdk所处的状态（必须实现该方法）
- (void) connectionStatusChanged: (PLVSessionState) sessionState;

@optional
// 推流sdk创建CameraSource（即相机被占用）以后，该接口会被调用，参数session为PLVSession的对象
- (void) didAddCameraSource:(PLVSession*)session;

- (void) detectedThroughput: (NSInteger) throughputInBytesPerSecond videoRate:(NSInteger) rate;
- (void) detectedThroughput: (NSInteger) throughputInBytesPerSecond;  //Depreciated, should use method above

@end

@interface PLVSession : NSObject

@property (nonatomic, readonly) PLVSessionState rtmpSessionState;   // 该属性为推流的状态属性
@property (nonatomic, strong, readonly) UIView* previewView;        // 该属性为推流视频的预览视图

/*! Setters / Getters for session properties */
@property (nonatomic, assign) CGSize            videoSize;      // 该属性为推流过程中视频的分辨率，在初始化时被确定，推流开始后不可更改
@property (nonatomic, assign) int               bitrate;        // 该属性为推流过程中视频的编码码率，在初始化时被确定，推流开始后不可更改
@property (nonatomic, assign) int               fps;            // 该属性为推流过程中视频的帧率，在初始化时被确定，推流开始后不可更改
@property (nonatomic, assign, readonly) BOOL    useInterfaceOrientation;    // 该属性表示是否使用应用的竖直方向作为视频的竖直方向，在初始化时被确定，推流开始后不可更改
@property (nonatomic, assign) PLVCameraState cameraState;       // 该属性表示采集视频时使用何种摄像头，推流开始后可以修改
@property (nonatomic, assign) BOOL          orientationLocked;  // 该属性表示推流过程中视频的竖直方向是否锁定，在初始化时被确定，推流开始后不可更改
@property (nonatomic, assign) BOOL          torch;              // 该属性表示是否开启相机的闪光灯，初始化时默认为不开启，推流开始后可以修改
@property (nonatomic, assign) float         videoZoomFactor;    // 该属性表示对原始视频进行缩放的比例，初始化时默认为1，推流开始后可以修改，其取值范围为(0, 1]
@property (nonatomic, assign) int           audioChannelCount;  // 该属性为音频采集编码过程中所使用的声道数，初始化时默认为2，推流开始后不可修改，其值只能为1或者2
@property (nonatomic, assign) float         audioSampleRate;    // 该属性为音频采集编码过程中所使用的采样率，初始化时默认为44100.0，推流开始后不可修改，其值只能为44100.0、22050，不建议对该值进行修改
@property (nonatomic, assign) float         micGain;            // 该属性表示麦克风音量增益因子，默认为1.0，推流开始后可以修改，其取值范围为[0, 1]
@property (nonatomic, assign) CGPoint       focusPointOfInterest;   // 该属性表示自动对焦时摄像头的对焦焦点，默认值为视频中心，推流开始后可以修改，其取值范围为[(0, 0), (1, 1)]，(0, 0)表示左上角，(1, 1)表示右下角
@property (nonatomic, assign) CGPoint       exposurePointOfInterest;// 该属性表示摄像头的测光中心点，默认值为视频中心，推流开始后可以修改，其取值范围为[(0, 0), (1, 1)]，(0, 0)表示左上角，(1, 1)表示右下角
@property (nonatomic, assign) BOOL          continuousAutofocus;    // 该属性表示是否开启摄像头实时自动对焦功能，默认为开启，推流开始后可以修改
@property (nonatomic, assign) BOOL          continuousExposure;     // 该属性表示是否开启摄像头动态测光功能，默认为开启，推流开始后可以修改
@property (nonatomic, assign) BOOL          useAdaptiveBitrate;     // 该属性表示视频编码过程中是否开启动态码率选项，默认为关闭，推流开始后不可修改（不建议使用动态码率）
@property (nonatomic, readonly) int         estimatedThroughput;    // 推流过程中与服务器协商后的网络带宽，位每秒（Byte Per Second）
@property (nonatomic, assign) PLVAspectMode  aspectMode;            // 该属性表示视频画面对窗口的填充方式，默认为PLVAspectModeFit，初始化后不可以修改
@property (nonatomic, assign) PLVFilter      filter;                // 该属性表示预览和推流过程中所使用的实时滤镜效果，默认为PLVFilterNormal，推流开始后可以修改

@property (nonatomic, assign) id<PLVSessionDelegate> delegate;

// -----------------------------------------------------------------------------
- (instancetype) initWithVideoSize:(CGSize)videoSize
                         frameRate:(int)fps
                           bitrate:(int)bps;

// -----------------------------------------------------------------------------
- (instancetype) initWithVideoSize:(CGSize)videoSize
                         frameRate:(int)fps
                           bitrate:(int)bps
           useInterfaceOrientation:(BOOL)useInterfaceOrientation;

// -----------------------------------------------------------------------------
- (instancetype) initWithVideoSize:(CGSize)videoSize
                         frameRate:(int)fps
                           bitrate:(int)bps
           useInterfaceOrientation:(BOOL)useInterfaceOrientation
                       cameraState:(PLVCameraState) cameraState;

// -----------------------------------------------------------------------------
- (instancetype) initWithVideoSize:(CGSize)videoSize
                         frameRate:(int)fps
                           bitrate:(int)bps
           useInterfaceOrientation:(BOOL)useInterfaceOrientation
                       cameraState:(PLVCameraState) cameraState
                        aspectMode:(PLVAspectMode) aspectMode;




// -----------------------------------------------------------------------------


// 验证登录频道和密码
+ (void)sessionLoginWithChannelId:(NSString *)channelId password:(NSString *)password success:(void(^)(NSString *successInfo))success failure:(void(^)(NSString *failureInfo))failure;


/**
 *  使用channelId和password来进行视频推流
 *
 *  @param channelId 频道号
 *  @param password  频道号的密码
 *  @param failure   推流失败返回的错误信息，如网络请求失败信息，登录错误信息等
 */
- (void)startRtmpSessionWithChannelId:(NSString *)channelId
                          andPassword:(NSString *)password
                              failure:(void(^)(NSString*  msg))failure;

// Depreciated, use method above
- (void) startRtmpSessionWithURL:(NSString*) rtmpUrl
                    andStreamKey:(NSString*) streamKey;

// 结束推流
- (void) endRtmpSession;

// 通过该接口可以获取相机采集到的原始画面
- (void) getCameraPreviewLayer: (AVCaptureVideoPreviewLayer**) previewLayer;


/*!
 *  Note that the rect you provide should be based on your video dimensions.  The origin
 *  of the image will be the center of the image (so if you put 0,0 as its position, it will
 *  basically end up with the bottom-right quadrant of the image hanging out at the top-left corner of
 *  your video)
 */
- (void) addPixelBufferSource: (UIImage*) image
                     withRect: (CGRect) rect;

@end
