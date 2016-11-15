//
//  PLVLivePreview.h
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFLiveKit.h"

#ifdef DEBUG
//#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define DLog(fmt, ...) NSLog((@"" fmt), ##__VA_ARGS__);
//#   define NSLog(format, ...) printf("[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String])    // 可用于iOS10的调试打印输出
#else
#   define DLog(...)
#endif

@interface PLVLivePreview : UIView

@property (nonatomic, copy) NSString *rtmpUrl;

// 推流模式：横屏或竖屏(默认横屏模式UIInterfaceOrientationMaskLandscape)
@property (nonatomic, assign) UIInterfaceOrientation supportedInterfaceOrientation;

// 音频配置（默认配置为LFLiveAudioQuality_High, sample rate: 44.1MHz audio bitrate: 128Kbps）
@property (nonatomic, assign) LFLiveAudioQuality audioQuality;

// 视频配置（默认配置为LFLiveVideoQuality_Low2, 分辨率： 360 *640 帧数：24 码率：800Kps）
@property (nonatomic, assign) LFLiveVideoQuality videoQuality;


@end
