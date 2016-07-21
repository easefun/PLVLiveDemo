//
//  CameraViewController.m
//  PolyvStreamerDemo
//
//  Created by ftao on 16/3/17.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "CameraController.h"
#import "PLVSession.h"
#import "SettingController.h"

@interface CameraController ()<PLVSessionDelegate> {
    // property state
    __weak IBOutlet UILabel *_videoSizeLB;
    __weak IBOutlet UILabel *_bitrateLB;
    __weak IBOutlet UILabel *_frameRateLB;
    __weak IBOutlet UILabel *_useInterfaceOrientationLB;
    __weak IBOutlet UILabel *_torchLB;
    __weak IBOutlet UILabel *_videoZoomFactorLB;
    __weak IBOutlet UILabel *_audioChannelCountLB;
    __weak IBOutlet UILabel *_audioSampleRateLB;
    __weak IBOutlet UILabel *_micGainLB;
    __weak IBOutlet UILabel *_focusPointOfInterestLB;
    __weak IBOutlet UILabel *_useAdaptiveBitrateLB;
    __weak IBOutlet UILabel *_estimatedThoughputLB;
}

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *streamButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (strong, nonatomic) IBOutlet UIView *stateView;

@property (nonatomic, assign) CGSize    videoSize;         // 视频分辨率，推流时此属性需要根据屏幕方向做宽高的替换
@property (nonatomic, assign) int       frameRate;
@property (nonatomic, assign) int       bitrate;

@property (nonatomic ,strong) PLVSession *session;


@end


@implementation CameraController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self initilizeSession];                  // 配置session
    [self setStateProperty];                  // 设置属性状态
    [self addObserver];                       // 设置监听
}


- (void)initilizeSession {
    
    if (_session.delegate) {                // security
        _session.delegate = nil;
        [_session endRtmpSession];
    }
    _session = [[PLVSession alloc] initWithVideoSize:self.videoSize frameRate:self.frameRate bitrate:self.bitrate useInterfaceOrientation:YES];
    _session.previewView.frame = self.previewView.bounds;
    [self.previewView addSubview:_session.previewView];
    _session.delegate = self;
    
    // 把直播状态、参数显示到最上端（session的preview会覆盖）
    [self.previewView bringSubviewToFront:self.stateLabel];
    [self.previewView bringSubviewToFront:self.stateView];
    
    // 添加水印在测试阶段，可能不稳定，建议512*512 400x242
    //    UIImage *image = [UIImage imageNamed:@"logo.png"];
    //    @try {
    //        [[NSOperationQueue new] addOperationWithBlock:^{
    //            sleep(0.2);
    //            if (image) {
    //                //[_session addPixelBufferSource:image withRect:CGRectMake(100, 100, 400, 400)];
    //            }else {
    //                NSLog(@"image can't be nil.");
    //            }
    //        }];
    //    }
    //    @catch (NSException *exception) {
    //        NSLog(@"%@,%@",exception.name,exception.reason);
    //    }
}

- (void)setStateProperty {
    _videoSizeLB.text =  NSStringFromCGSize(_session.videoSize);
    _bitrateLB.text = [NSString stringWithFormat:@"%d",_session.bitrate];
    _frameRateLB.text = [NSString stringWithFormat:@"%d",_session.fps];
    _useInterfaceOrientationLB.text = [NSString stringWithFormat:@"%@",_session.useInterfaceOrientation ? @"YES" : @"NO"];
    _torchLB.text = [NSString stringWithFormat:@"%@",_session.torch ? @"YES" : @"NO"];
    _videoZoomFactorLB.text = [NSString stringWithFormat:@"%.0f",_session.videoZoomFactor];
    _audioChannelCountLB.text = [NSString stringWithFormat:@"%d",_session.audioChannelCount];
    _audioSampleRateLB.text = [NSString stringWithFormat:@"%0.f",_session.audioSampleRate];
    _micGainLB.text = [NSString stringWithFormat:@"%.0f",_session.micGain];
    _focusPointOfInterestLB.text = NSStringFromCGPoint(_session.focusPointOfInterest);
    _useAdaptiveBitrateLB.text = [NSString stringWithFormat:@"%@",_session.useAdaptiveBitrate ? @"YES" : @"NO"];
    _estimatedThoughputLB.text = [NSString stringWithFormat:@"%d",_session.estimatedThroughput];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationDidRotation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];                      // 监听状态栏位置发生变化的通知
}


// 根据状态栏的位置，自动设置size适合的宽高
- (CGSize)autoSuitableSize:(CGSize)videoSize {
    CGSize newSize;
    BOOL isShouldOverturn;
    NSInteger interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (((interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight ) && videoSize.height > videoSize.width )                                                                                      // 状态栏在左右 高大于宽
        || (interfaceOrientation == UIInterfaceOrientationPortrait && videoSize.width > videoSize.height) )    // 状态栏在上  宽大于高
    {
        isShouldOverturn = YES;
    }
    return newSize = isShouldOverturn ? CGSizeMake(videoSize.height, videoSize.width) : videoSize;
}


#pragma mark - 检测屏幕旋转

- (void)statusBarOrientationDidRotation:(NSNotification *)nf {

    if (_session.rtmpSessionState == PLVSessionStateStarted) {      // 推流中

        NSInteger interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortrait:            // 竖屏
            case UIInterfaceOrientationLandscapeLeft:       // 横屏
            case UIInterfaceOrientationLandscapeRight: {    // ..
                
                [self initilizeSession];
                
                [_session startRtmpSessionWithChannelId:self.channelId andPassword:self.password failure:^(NSString *msg) {      // 推流
                    NSLog(@"%@",msg);
                }];
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark - PLVSessionDelegate代理方法

- (void)connectionStatusChanged:(PLVSessionState)sessionState {

    // 使用sizeclass和aotuLayout做屏幕适配和约束，需要回主线程更新UI
    switch( sessionState ) {
        case PLVSessionStateStarting: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.streamButton setImage:[UIImage imageNamed:@"block"] forState:UIControlStateNormal];
                self.stateLabel.text = @"正在连接...";
                self.settingButton.enabled = NO;
            });
        }
            break;
            
        case PLVSessionStateStarted: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.streamButton setImage:[UIImage imageNamed:@"to_stop"] forState:UIControlStateNormal];
                self.stateLabel.text = @"直播中...";
                [self.stateLabel setTextColor:[UIColor greenColor]];
                [self setStateProperty];
                self.settingButton.enabled = NO;
            });
        }
            break;
            
        default: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.streamButton setImage:[UIImage imageNamed:@"to_start"] forState:UIControlStateNormal];
                self.stateLabel.text = @"未直播";
                [self.stateLabel setTextColor:[UIColor redColor]];
                self.settingButton.enabled = YES;
            });
        }
            break;
    }
}

#pragma mark - 点击事件

// streamButton
- (IBAction)streamButton:(id)sender {
    
    switch( _session.rtmpSessionState ) {
            
        case PLVSessionStateStarting:
        case PLVSessionStateStarted: {
            [_session endRtmpSession];                                                              // 结束推流
        }
            break;
            
        default: {
            if (!CGSizeEqualToSize(_videoSize, [self autoSuitableSize:_videoSize])) {
                [self initilizeSession];                                                    // 当前videoSize是否为合适的宽高
            }
            //  使用channelId(频道号)和password(密码)进行推流
            [_session startRtmpSessionWithChannelId:self.channelId andPassword:self.password failure:^(NSString *msg) {
                NSLog(@"%@",msg);
            }];
        }
            break;
    }
}

// 退出
- (IBAction)cancelButtonPress:(UIButton *)sender {
    
    //注意1：在当前控制器销毁时（dismissViewController、popViewController等）一般加上此行代码，防止页面退出后继续再次执行代理方法
    //如果在connectionStatusChanged：代理方法中使用了回到主线程更新，此处需要设置代理人为空，否则可能因为实例对象被销毁确继续在主线程调用其方法造成崩溃
    //注意2：此方法需要在endRtmpSession方法调用之前
    _session.delegate = nil;
    
    [_session endRtmpSession];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 设置视频的filter(特效)
- (IBAction)filterButtonpress:(UIButton *)sender {

    switch (_session.filter) {
        case PLVFilterNormal:
            [_session setFilter:PLVFilterGray];
            break;
        case PLVFilterGray:
            [_session setFilter:PLVFilterInvertColors];
            break;
        case PLVFilterInvertColors:
            [_session setFilter:PLVFilterSepia];
            break;
        case PLVFilterSepia:
            [_session setFilter:PLVFilterNormal];
            break;
        default:
            break;
    }
}

// 摄像头翻转
- (IBAction)switchButtonPress:(UIButton *)sender {
    
    if ( _session.cameraState ) {
        [_session setCameraState:PLVCameraStateFront];
    }else {
        [_session setCameraState:PLVCameraStateBack];
    }
}


// 设置(待优化)
- (IBAction)settingButtonPress:(UIButton *)sender {

    SettingController *settingVC = [SettingController new];
    settingVC.videoSize = _session.videoSize;
    settingVC.frameRate = _session.fps;
    settingVC.bitrate = _session.bitrate;
    
    //__block CameraViewController *vc = self;
    settingVC.settingBlock = ^(CGSize videoSize, int frameRate, int bitrate) {
        NSLog(@"videoSize:%@,frameRate:%d,bitRate:%d",NSStringFromCGSize(videoSize),frameRate,bitrate);
        self.videoSize = videoSize;
        self.frameRate = frameRate;
        self.bitrate = bitrate;
        
        [self initilizeSession];
    };
    
    [self.navigationController pushViewController:settingVC animated:YES];
}


#pragma mark - 重写get方法

- (CGSize)videoSize {
    if (CGSizeEqualToSize(_videoSize, CGSizeZero)) {
        _videoSize = CGSizeMake(720, 1280);
    }
    return [self autoSuitableSize:_videoSize];
}


- (int)frameRate {
    if (!_frameRate) {
        _frameRate = 15;
    }
    return _frameRate;
}

- (int)bitrate {
    if (!_bitrate) {
        _bitrate = 800*1000;
    }
    return _bitrate;
}



-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];  // 移除监听
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [_session endRtmpSession];                  // 内存警告，结束推流
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
