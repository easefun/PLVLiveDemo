//
//  CameraViewController.m
//  PolyvStreamerDemo
//
//  Created by FT on 16/3/17.
//  Copyright © 2016年 polyv. All rights reserved.
//

#import "CameraViewController.h"
#import "PLVSession.h"
#import "SettingTableViewController.h"

//遵循PVSessionDelegate的协议
@interface CameraViewController ()<PLVSessionDelegate>
{
    // state property
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

@property (nonatomic ,strong)PLVSession *session;

@property (nonatomic, assign)CGSize videoSize;
@property (nonatomic, assign)int frameRate;
@property (nonatomic, assign)int bitrate;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // 初始化参数
    self.videoSize = CGSizeMake(720, 1280);
    self.frameRate = 25;
    self.bitrate = 600*1024;
    
    // 配置session
    [self initSessionConfiguration];

    
    // 设置属性状态
    [self setStateProperty];
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotation:) name:UIDeviceOrientationDidChangeNotification object:nil];          // 物理旋转
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];  // status rotation
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}


// 配置session方法
- (void)initSessionConfiguration {
    
    // security
    if (_session.delegate) {
        _session.delegate = nil;
        [_session endRtmpSession];
    }
    
    _session = [[PLVSession alloc] initWithVideoSize:_videoSize frameRate:_frameRate bitrate:_bitrate useInterfaceOrientation:YES];
   
    _session.previewView.frame = self.previewView.bounds;
    [self.previewView addSubview:_session.previewView];
    
    _session.delegate = self;       // set delegate
    
    // 把直播状态、参数显示到最上端（session的preview会覆盖）
    [self.previewView bringSubviewToFront:self.stateLabel];
    [self.previewView bringSubviewToFront:self.stateView];

}

// 重写set方法，获取一个值时判断横竖屏的size
- (void)setVideoSize:(CGSize)videoSize {
    
    NSInteger interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (((interfaceOrientation == UIDeviceOrientationLandscapeLeft || interfaceOrientation == UIDeviceOrientationLandscapeRight ) && videoSize.height > videoSize.width )             //  横屏但高大于宽
        || (interfaceOrientation == UIDeviceOrientationPortrait && videoSize.width > videoSize.height) )  // 竖屏但宽大于高
    {
        CGSize newSize = videoSize;
        _videoSize = CGSizeMake(newSize.height, newSize.width);
    }else {
        
        _videoSize = videoSize;
    }

    
}

#pragma mark - 检测屏幕旋转

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    if (_session.rtmpSessionState == PLVSessionStateStarting) {
        return NO;
    }else {
        return YES;
    }
}


// iOS2.0至8.0
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    // 根据横竖屏改变分辨率
    CGSize currentSize = _videoSize;
    if ( (toInterfaceOrientation == UIInterfaceOrientationPortrait && currentSize.width > currentSize.height )
        || (
            (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) && currentSize.width < currentSize.height
            ) ) {
            _videoSize = CGSizeMake(currentSize.height, currentSize.width);
        }

    if (_session.rtmpSessionState == PLVSessionStateStarted) {      // tointerface
      
        switch (toInterfaceOrientation) {
            case UIInterfaceOrientationPortrait:            // 竖屏
            case UIInterfaceOrientationLandscapeLeft:       // 横屏
            case UIInterfaceOrientationLandscapeRight: {    // 横屏
                
                // security
                if (_session.delegate) {
                    _session.delegate = nil;
                    [_session endRtmpSession];
                }
                
                // 旋屏自己设置_videoSize
                _session = [[PLVSession alloc] initWithVideoSize:_videoSize frameRate:_frameRate bitrate:_bitrate useInterfaceOrientation:YES];
                
                _session.previewView.frame = self.previewView.bounds;
                [self.previewView addSubview:_session.previewView];
                
                _session.delegate = self;       // set delegate
                
                // 把直播状态、参数显示到最上端（session的preview会覆盖）
                [self.previewView bringSubviewToFront:self.stateLabel];
                [self.previewView bringSubviewToFront:self.stateView];
                
                // 重新配置session,会获取到不争取的videoSize
                //[self initSessionConfiguration];
                
                // 重新推流
                [self streamButton:nil];
            }
                break;
                
            default:
                break;
        }
    }

}

// iOS8.0之后
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
//}


#pragma mark - 设置转屏时的推流方向

#pragma mark - PLVSessionDelegate的代理方法

- (void)connectionStatusChanged:(PLVSessionState)sessionState {

    //注意：如果使用sizeclass和aotuLayout做屏幕适配和约束，在更新UI时需要回到主线程更新

    switch( sessionState ) {
        case PLVSessionStateStarting:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.streamButton setImage:[UIImage imageNamed:@"block"] forState:UIControlStateNormal];
                self.stateLabel.text = @"正在连接";
                self.settingButton.enabled = NO;
            });
        }
            break;
            
        case PLVSessionStateStarted:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.streamButton setImage:[UIImage imageNamed:@"to_stop"] forState:UIControlStateNormal];
                self.stateLabel.text = @"正在直播";
                [self setStateProperty];
                
                self.settingButton.enabled = NO;
            });
        }
            break;
            
        default:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.streamButton setImage:[UIImage imageNamed:@"to_start"] forState:UIControlStateNormal];
                self.stateLabel.text = @"未直播";
                self.settingButton.enabled = YES;
            });
        }
            break;
    }

}

#pragma mark - 点击streamButton时调用

- (IBAction)streamButton:(id)sender {
    
    switch( _session.rtmpSessionState ) {
            
        case PLVSessionStateNone:
        case PLVSessionStatePreviewStarted:
        case PLVSessionStateEnded:
        case PLVSessionStateError:
            
            //使用channelId（直播频道）和password（密码）参数进行推流
            [_session startRtmpSessionWithChannelId:@"99778" andPassword:@"123456"failure:^(NSString *msg) {
                
                NSLog(@"--%@",msg);
            }];
            break;
            
        default:
            //结束推流
            [_session endRtmpSession];
            break;
    }
}

#pragma mark - 退出按钮点击事件

- (IBAction)cancelButtonPress:(UIButton *)sender {
    
    //注意1：在当前控制器销毁时（dismissViewController、popViewController等）一般加上此行代码，防止页面退出后继续再次执行代理方法
    //如果在connectionStatusChanged：代理方法中使用了回到主线程更新，此处需要设置代理人为空，否则可能因为实例对象被销毁确继续在主线程调用其方法造成崩溃
    //注意2：此方法需要在endRtmpSession方法调用之前
    _session.delegate = nil;
    
    [_session endRtmpSession];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 视屏特效按钮点击事件

- (IBAction)filterButtonpress:(UIButton *)sender {
    
    //设置视频的filter（特效）
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


#pragma mark - 摄像头翻转按钮点击事件

- (IBAction)switchButtonPress:(UIButton *)sender {
    
    if ( _session.cameraState ) {
        [_session setCameraState:PLVCameraStateFront];
    }else {
        [_session setCameraState:PLVCameraStateBack];
    }
}


#pragma mark - 视频设置按钮点击事件

- (IBAction)settingButtonPress:(UIButton *)sender {

    SettingTableViewController *settingVC = [SettingTableViewController new];
    settingVC.videoSize = _session.videoSize;
    settingVC.frameRate = _session.fps;
    settingVC.bitrate = _session.bitrate;
    
    //__block CameraViewController *vc = self;
    
    //代码块回调，用于反向传值
    settingVC.settingBlock = ^(CGSize videoSize, int frameRate, int bitrate) {
        NSLog(@"videoSize:%@,frameRate:%d,bitRate:%d",NSStringFromCGSize(videoSize),frameRate,bitrate);
        self.videoSize = videoSize;
        self.frameRate = frameRate;
        self.bitrate = bitrate;

        // 重新初始化session
        [self initSessionConfiguration];
    };
    
    [self.navigationController pushViewController:settingVC animated:YES];
}


#pragma mark - 初始化状态属性

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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [_session endRtmpSession];
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
