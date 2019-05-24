//
//  PLVLivePreview.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVLivePreview.h"
#import <PLVLiveKit/LFLiveKit.h>
#import "PLVRtmpSetting.h"
#import "UIView+YYAdd.h"

inline static NSString *formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }
    if (bytes <= 0) {
        return @"0 KB/s";
    }
    
    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2fMB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1fKB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ldB/s", (long)bytes_per_sec];
    }
}

@interface PLVLivePreview () <LFLiveSessionDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *waterMarkButton;
@property (nonatomic, strong) UIButton *startLiveButton;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) LFLiveSession *liveSession;

@end

@implementation PLVLivePreview

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.containerView];
        [self.containerView addSubview:self.stateLabel];
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.cameraButton];
        [self.containerView addSubview:self.beautyButton];
        [self.containerView addSubview:self.waterMarkButton];
        [self.containerView addSubview:self.rateLabel];
        [self.containerView addSubview:self.startLiveButton];
    }
    return self;
}

#pragma mark --

- (void)setupSeesion {
    self.liveSession = [[LFLiveSession alloc] initWithAudioConfiguration:[PLVRtmpSetting sharedRtmpSetting].audioConfig videoConfiguration:[PLVRtmpSetting sharedRtmpSetting].videoConfig captureType:LFLiveCaptureDefaultMask];
    self.liveSession.captureDevicePosition = AVCaptureDevicePositionBack;   // 开启后置摄像头(默认前置)
    self.liveSession.delegate = self;
    self.liveSession.preView = self;
    self.liveSession.showDebugInfo = YES;
    self.liveSession.reconnectCount = 3;
    self.liveSession.reconnectInterval = 3;
    
    [self.liveSession setRunning:YES];
    
    // 本地存储
    //self.session.saveLocalVideo = YES;
    //NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
    //unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    //NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    //self.session.saveLocalVideoPath = movieURL;
    
    //[self addWaterMark];
}

- (void)addWaterMark {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.alpha = 0.8;
    imageView.frame = CGRectMake(50, 110, 80, 80);
    imageView.image = [UIImage imageNamed:@"pet"];
    self.liveSession.warterMarkView = imageView;
}

#pragma mark - Actions

- (void)startLiveButton:(UIButton *)sender {
    switch (self.liveSession.state) {
        case LFLiveError:
            [self.liveSession stopLive];
        case LFLiveReady:
        case LFLiveStop: {
            [self.startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
            [self.startLiveButton setBackgroundColor:[UIColor redColor]];
            // 配置推流Info
            LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
            stream.appVersionInfo = PLVRTMP_SDK_VERSION;
            stream.url = [PLVRtmpSetting sharedRtmpSetting].rtmpUrl;
            [self.liveSession startLive:stream];
        } break;
        case LFLivePending:
        case LFLiveStart:
            [self.liveSession stopLive];
            break;
        default:
            break;
    }
}

- (void)waterMarkButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self addWaterMark];
    }else {
        self.liveSession.warterMarkView = nil;
    }
}

- (void)beautyButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.liveSession.beautyFace = !sender.isSelected;
}

- (void)cameraButton:(UIButton *)sender {
    AVCaptureDevicePosition devicePositon = self.liveSession.captureDevicePosition;
    self.liveSession.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (void)closeButton:(UIButton *)sender {
    [self.liveSession stopLive];
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
    [self removeFromSuperview];
}

#pragma mark -- <LFStreamingSessionDelegate>

- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSLog(@"%s liveStateDidChange: %lu", __FUNCTION__,state);
    switch (state) {
        case LFLiveReady:
        case LFLiveStop: {
            _stateLabel.text = @"未连接";
            [self.startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
            [self.startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
            _rateLabel.text = @"0KB/s";
        } break;
        case LFLivePending:
            _stateLabel.text = @"连接中";
            break;
        case LFLiveStart: {
            _stateLabel.text = @"已连接";
            [self.startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
            [self.startLiveButton setBackgroundColor:[UIColor redColor]];
        } break;
        case LFLiveError: {
            _stateLabel.text = @"连接错误";
            [self.startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
            [self.startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
            _rateLabel.text = @"0KB/s";
        } break;
        default:
            break;
    }
}

- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
    NSString *speed  = formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli);
    self.rateLabel.text = [NSString stringWithFormat:@"↑%@",speed];
    //NSLog(@"%s debugInfo: %@ %@", __FUNCTION__,speed,debugInfo);
}

- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    NSLog(@"%s errorCode: %ld", __FUNCTION__,errorCode);
}

#pragma mark - Getter

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.frame = self.bounds;
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _containerView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 40)];
        _stateLabel.text = @"未连接";
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
    }
    return _stateLabel;
}

- (UILabel *)rateLabel {
    if (!_rateLabel) {
        _rateLabel = [UILabel new];
        _rateLabel.size = CGSizeMake(70, 25);
        _rateLabel.top = _closeButton.bottom + 10;
        _rateLabel.right = _closeButton.right - 5;
        _rateLabel.text = @"0KB/s";
        _rateLabel.textColor = [UIColor whiteColor];
        _rateLabel.font = [UIFont boldSystemFontOfSize:12.f];
        _rateLabel.textAlignment = NSTextAlignmentRight;
        _rateLabel.adjustsFontSizeToFitWidth = YES;
        _rateLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        _rateLabel.layer.cornerRadius = 8.0;
        _rateLabel.layer.masksToBounds = YES;
    }
    return _rateLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton new];
        _closeButton.size = CGSizeMake(44, 44);
        _closeButton.left = self.width - 10 - _closeButton.width;
        _closeButton.top = 20;
        [_closeButton setImage:[UIImage imageNamed:@"plv_close"] forState:UIControlStateNormal];
        _closeButton.exclusiveTouch = YES;
        [_closeButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton new];
        _cameraButton.size = CGSizeMake(44, 44);
        _cameraButton.origin = CGPointMake(_closeButton.left - 10 - _cameraButton.width, 20);
        [_cameraButton setImage:[UIImage imageNamed:@"plv_camera"] forState:UIControlStateNormal];
        _cameraButton.exclusiveTouch = YES;
        [_cameraButton addTarget:self action:@selector(cameraButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)beautyButton {
    if (!_beautyButton) {
        _beautyButton = [UIButton new];
        _beautyButton.size = CGSizeMake(44, 44);
        _beautyButton.origin = CGPointMake(_cameraButton.left - 10 - _beautyButton.width, 20);
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateNormal];
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateSelected];
        _beautyButton.exclusiveTouch = YES;
        [_beautyButton addTarget:self action:@selector(beautyButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyButton;
}

- (UIButton *)waterMarkButton {
    if (!_waterMarkButton) {
        _waterMarkButton = [UIButton new];
        _waterMarkButton.size = CGSizeMake(44, 44);
        _waterMarkButton.origin = CGPointMake(_beautyButton.left - 10 - _waterMarkButton.width , 20);
        [_waterMarkButton setImage:[UIImage imageNamed:@"plv_watermark_close"] forState:UIControlStateNormal];
        [_waterMarkButton setImage:[UIImage imageNamed:@"plv_watermark"] forState:UIControlStateSelected];
        [_waterMarkButton addTarget:self action:@selector(waterMarkButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _waterMarkButton;
}

- (UIButton *)startLiveButton {
    if (!_startLiveButton) {
        _startLiveButton = [UIButton new];
        _startLiveButton.size = CGSizeMake(self.width / 2, 44);
        _startLiveButton.centerX = self.centerX;
        _startLiveButton.bottom = self.height - 50;
        _startLiveButton.layer.cornerRadius = _startLiveButton.height/2;
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startLiveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        _startLiveButton.exclusiveTouch = YES;
        [_startLiveButton addTarget:self action:@selector(startLiveButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startLiveButton;
}

@end

