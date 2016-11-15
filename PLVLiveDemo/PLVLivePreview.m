//
//  PLVLivePreview.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVLivePreview.h"
#import "UIControl+YYAdd.h"
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

@interface PLVLivePreview ()<LFLiveSessionDelegate>

@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *startLiveButton;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) LFLiveDebug *debugInfo;
@property (nonatomic, strong) LFLiveSession *session;
@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UILabel *rateLabel;

@end

@implementation PLVLivePreview

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self requestAccessForVideo];
        [self requestAccessForAudio];
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.stateLabel];
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.cameraButton];
        [self.containerView addSubview:self.beautyButton];
        [self.containerView addSubview:self.rateLabel];
        [self.containerView addSubview:self.startLiveButton];
    }
    return self;
}

#pragma mark -- Public Method
- (void)requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权，可继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [_self.session setRunning:YES];
            });
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            
            break;
        default:
            break;
    }
}

- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSLog(@"liveStateDidChange: %ld", state);
    switch (state) {
       
        case LFLiveReady:
        case LFLiveStop: {
            _stateLabel.text = @"未连接";
            [self.startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
            [self.startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
            _rateLabel.text = @"0KB/s";
        }
            break;
        case LFLivePending:
            _stateLabel.text = @"连接中";
            break;
        case LFLiveStart: {
            _stateLabel.text = @"已连接";
            [self.startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
            [self.startLiveButton setBackgroundColor:[UIColor redColor]];
        }
            
            break;
        case LFLiveError: {
            _stateLabel.text = @"连接错误";
            [self.startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
            [self.startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
            _rateLabel.text = @"0KB/s";
        }
            break;
        
        default:
            break;
    }
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
    NSString *speed  = formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli);
    self.rateLabel.text = speed;
    NSLog(@"debugInfo: %@ %@", speed,debugInfo);
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    NSLog(@"errorCode: %ld", errorCode);
}

#pragma mark -- Getter Setter
- (LFLiveSession *)session {
    if (!_session) {
        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
        switch (self.videoQuality) {
            case 0: {
                videoConfiguration.videoSize = (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait)?CGSizeMake(360, 640):CGSizeMake(640, 360);
                videoConfiguration.videoFrameRate = 15;
                //videoConfiguration.videoBitRate = 500*1024;
                videoConfiguration.videoBitRate = 400*1024;
                videoConfiguration.videoMaxBitRate = 800*1024;
                videoConfiguration.videoMinBitRate = 400*1024;
                videoConfiguration.videoMaxKeyframeInterval = 48;
                videoConfiguration.sessionPreset = LFCaptureSessionPreset360x640;
            }
                break;
            case 1: {
                videoConfiguration.videoSize = (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait)?CGSizeMake(360, 640):CGSizeMake(640, 360);
                videoConfiguration.videoFrameRate = 20;
                videoConfiguration.videoBitRate = 650*1024;
                videoConfiguration.videoMaxBitRate = 8500*1024;
                videoConfiguration.videoMinBitRate = 450*1024;
                videoConfiguration.videoMaxKeyframeInterval = 48;
                videoConfiguration.sessionPreset = LFCaptureSessionPreset360x640;
            }
                break;
            case 2: {
                videoConfiguration.videoSize = (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait)?CGSizeMake(540, 960):CGSizeMake(960, 540);
                videoConfiguration.videoFrameRate = 15;
                //videoConfiguration.videoBitRate = 800*1024;
                videoConfiguration.videoBitRate = 600*1024;
                videoConfiguration.videoMaxBitRate = 1000*1024;
                videoConfiguration.videoMinBitRate = 500*1024;
                videoConfiguration.videoMaxKeyframeInterval = 48;
                videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;
            }
                break;
            case 3: {
                videoConfiguration.videoSize = (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait)?CGSizeMake(540, 960):CGSizeMake(960, 540);
                videoConfiguration.videoFrameRate = 20;
                videoConfiguration.videoBitRate = 800*1024;
                videoConfiguration.videoMaxBitRate = 1100*1024;
                videoConfiguration.videoMinBitRate = 500*1024;
                videoConfiguration.videoMaxKeyframeInterval = 48;
                videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;
            }
                break;
            case 4: {
                videoConfiguration.videoSize = (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait)?CGSizeMake(720, 1280):CGSizeMake(1280, 720);
                videoConfiguration.videoFrameRate = 15;
//                videoConfiguration.videoBitRate = 1000*1024;
                videoConfiguration.videoBitRate = 900*1024;
                videoConfiguration.videoMaxBitRate = 1200*1024;
                videoConfiguration.videoMinBitRate = 700*1024;
                videoConfiguration.videoMaxKeyframeInterval = 48;
                videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
            }
                break;
            case 5: {
                videoConfiguration.videoSize = (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait)?CGSizeMake(720, 1280):CGSizeMake(1280, 720);
                videoConfiguration.videoFrameRate = 20;
                videoConfiguration.videoBitRate = 1200*1024;
                videoConfiguration.videoMaxBitRate = 1500*1024;
                videoConfiguration.videoMinBitRate = 900*1024;
                videoConfiguration.videoMaxKeyframeInterval = 48;
                videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
            }
                break;
                
            default: {  // 默认：同3
                videoConfiguration.videoSize = (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait)?CGSizeMake(540, 960):CGSizeMake(960, 540);
                videoConfiguration.videoFrameRate = 20;
                videoConfiguration.videoBitRate = 800*1024;
                videoConfiguration.videoMaxBitRate = 1100*1024;
                videoConfiguration.videoMinBitRate = 500*1024;
                videoConfiguration.videoMaxKeyframeInterval = 48;
                videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;
            }
                break;
        }
        videoConfiguration.autorotate = YES;
        videoConfiguration.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];
        _session.captureDevicePosition = AVCaptureDevicePositionBack;   // 开启后置摄像头(默认前置)
        
       
        /**    自己定制单声道  */
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 1;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_64Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */
        
        /**    自己定制高质量音频96K */
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:[LFLiveVideoConfiguration defaultConfiguration]];
         */
        
        /**    自己定制高质量音频96K 分辨率设置为540*960 方向竖屏 */
        
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_96Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         
         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(540, 960);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 24;
         videoConfiguration.videoMaxKeyframeInterval = 48;
         videoConfiguration.orientation = UIInterfaceOrientationPortrait;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset540x960;
         
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */
        
        
        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */
        
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         
         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(720, 1280);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 15;
         videoConfiguration.videoMaxKeyframeInterval = 30;
         videoConfiguration.landscape = NO;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset360x640;
         
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */
        
        
        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向横屏  */
        
        /*
         LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
         audioConfiguration.numberOfChannels = 2;
         audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
         audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
         
         LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
         videoConfiguration.videoSize = CGSizeMake(1280, 720);
         videoConfiguration.videoBitRate = 800*1024;
         videoConfiguration.videoMaxBitRate = 1000*1024;
         videoConfiguration.videoMinBitRate = 500*1024;
         videoConfiguration.videoFrameRate = 15;
         videoConfiguration.videoMaxKeyframeInterval = 30;
         videoConfiguration.landscape = YES;
         videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
         
         _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
         */
        
        _session.delegate = self;
        _session.showDebugInfo = YES;
        _session.preView = self;
        
        /*本地存储*/
        //        _session.saveLocalVideo = YES;
        //        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mp4"];
        //        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        //        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        //        _session.saveLocalVideoPath = movieURL;
        
        
        // 开启此可选择注释掉GPUImageFramebuffer->unlock中NSAssert
         //UIImageView *imageView = [[UIImageView alloc] init];
         //imageView.alpha = 0.8;
         //imageView.frame = CGRectMake(100, 100, 40, 40);
         //imageView.image = [UIImage imageNamed:@"sheep"];
         //_session.warterMarkView = imageView;
        
    }
    return _session;
}

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

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton new];
        _closeButton.size = CGSizeMake(44, 44);
        _closeButton.left = self.width - 10 - _closeButton.width;
        _closeButton.top = 20;
        [_closeButton setImage:[UIImage imageNamed:@"plv_close"] forState:UIControlStateNormal];
        _closeButton.exclusiveTouch = YES;
        __weak typeof(self) weakSelf = self;
        [_closeButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            
            [weakSelf.session stopLive];
            [weakSelf.viewController dismissViewControllerAnimated:YES completion:nil];
            [weakSelf removeFromSuperview];
        }];
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
        __weak typeof(self) _self = self;
        [_cameraButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            AVCaptureDevicePosition devicePositon = _self.session.captureDevicePosition;
            _self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        }];
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
        __weak typeof(self) _self = self;
        [_beautyButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
            _self.session.beautyFace = !_self.session.beautyFace;
            _self.beautyButton.selected = !_self.session.beautyFace;
        }];
    }
    return _beautyButton;
}

- (UILabel *)rateLabel {
    if (!_rateLabel) {
        _rateLabel = [UILabel new];
        _rateLabel.size = CGSizeMake(60, 40);
        _rateLabel.origin = CGPointMake(_beautyButton.left-10-_rateLabel.width, 20);
        _rateLabel.text = @"0KB/s";
        _rateLabel.textColor = [UIColor whiteColor];
        _rateLabel.font = [UIFont boldSystemFontOfSize:12.f];
    }
    return _rateLabel;
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
        [_startLiveButton addTarget:self action:@selector(startLiveButtonClick) forControlEvents:UIControlEventTouchUpInside];

    }
    return _startLiveButton;
}

- (void)startLiveButtonClick {
    switch (_session.state) {
        case LFLiveError:
            [self.session stopLive];
        case LFLiveReady:
        case LFLiveStop: {
            LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
            stream.url = self.rtmpUrl;
            //stream.url = @"rtmp://urlive.videocc.net/recordf/8754c4f11620160821175835488";
            [self.session startLive:stream];
            // 先改变颜色，降低感官的延迟度
            [self.startLiveButton setTitle:@"结束直播" forState:UIControlStateNormal];
            [self.startLiveButton setBackgroundColor:[UIColor redColor]];
        }
            break;
    
        case LFLivePending:
        case LFLiveStart:
            [self.session stopLive];
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    NSLog(@"");
}

@end

