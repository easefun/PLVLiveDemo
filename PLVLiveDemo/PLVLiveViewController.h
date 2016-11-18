//
//  PLVLiveViewController.h
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVLivePreview.h"

@interface PLVLiveViewController : UIViewController

@property (nonatomic, copy) NSString *rtmpUrl;

// 支持横屏或竖屏模式(默认横屏模式UIInterfaceOrientationMaskLandscape)
@property (nonatomic, assign) UIInterfaceOrientation supportedInterfaceOrientation;

@property (nonatomic, assign) NSInteger videoQuality;

// 音频配置（默认配置为LFLiveAudioQuality_High, sample rate: 44.1MHz audio bitrate: 128Kbps）
//@property (nonatomic, assign) LFLiveAudioQuality audioQuality;

// 视频配置（默认配置为LFLiveVideoQuality_Low2, 分辨率： 360 *640 帧数：24 码率：800Kps）
//@property (nonatomic, assign) LFLiveVideoQuality videoQuality;

@end
