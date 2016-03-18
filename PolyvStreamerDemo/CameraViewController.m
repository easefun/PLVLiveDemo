//
//  CameraViewController.m
//  PolyvStreamerDemo
//
//  Created by FT on 16/3/17.
//  Copyright © 2016年 polyv. All rights reserved.
//

#import "CameraViewController.h"
#import "PLVSession.h"

//遵循PVSessionDelegate的协议
@interface CameraViewController ()<PLVSessionDelegate>

@property (nonatomic ,strong)PLVSession *session;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 

    //初始化session
    CGSize videoSize = CGSizeMake(1280, 720);
    
    _session = [[PLVSession alloc] initWithVideoSize:videoSize frameRate:25 bitrate:600*1024 useInterfaceOrientation:YES];
   
    [self.previewView addSubview:_session.previewView];
    _session.previewView.frame = self.previewView.bounds;
    _session.delegate = self;
    
    
    //把直播状态显示到最上端
    [self.previewView bringSubviewToFront:self.stateLabel];
}

#pragma mark - 点击streamButton时调用

- (IBAction)streamButton:(id)sender {
    
    switch( _session.rtmpSessionState ) {
        
        case PLVSessionStateNone:
        case PLVSessionStatePreviewStarted:
        case PLVSessionStateEnded:
        case PLVSessionStateError:

            //使用channelId（直播频道）和password（密码）参数进行推流
            [_session startRtmpSessionWithChannelId:@"99778" andPassword:@"123456"];
            break;
            
        default:
            //结束推流
            [_session endRtmpSession];
            break;
    }
 
}


#pragma mark - PLVSessionDelegate的代理方法

- (void)connectionStatusChanged:(PLVSessionState)sessionState {

    //注意：如果使用sizeclass和aotuLayout做屏幕适配和约束，在更新UI时需要回到主线程更新
    dispatch_async(dispatch_get_main_queue(), ^{

        switch( sessionState ) {
            case PLVSessionStateStarting:
                [self.streamButton setImage:[UIImage imageNamed:@"block.png"] forState:UIControlStateNormal];
                self.stateLabel.text = @"正在连接";
                break;
                
            case PLVSessionStateStarted:
                [self.streamButton setImage:[UIImage imageNamed:@"to_stop.png"] forState:UIControlStateNormal];
                self.stateLabel.text = @"正在直播";
                break;
                
                
            default:

                [self.streamButton setImage:[UIImage imageNamed:@"to_start.png"] forState:UIControlStateNormal];
                self.stateLabel.text = @"未直播";
                
                break;
        }
    
    });

}



- (IBAction)cancelButtonPress:(UIButton *)sender {
    

    [_session endRtmpSession];
    
    //如果在connectionStatusChanged：代理方法中使用了回到主线程更新，此处需要设置代理人为空，否则可能因为实例对象被销毁确继续在主线程调用其方法造成崩溃
    _session.delegate = nil;

    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 视屏填充方式


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


#pragma mark - 摄像头翻转

- (IBAction)switchButtonPress:(UIButton *)sender {
    
    if ( _session.cameraState ) {
        [_session setCameraState:PLVCameraStateFront];
    }else {
        [_session setCameraState:PLVCameraStateBack];
    }

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
