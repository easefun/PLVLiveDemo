//
//  PLVLiveViewController.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVLiveViewController.h"
#import <PolyvLiveAPI/PLVLiveAPI.h>
#import <PLVChatManager/PLVChatManager.h>
#import "ZJZDanMu.h"
#import "PLVChannel.h"

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PLVLiveViewController ()<SocketIODelegate>

@property (nonatomic, strong) PLVLivePreview *livePreview;
@property (nonatomic, strong) PLVChatSocket *chatSocket;
@property (nonatomic, strong) ZJZDanMu *danmuLayer;

@end

@implementation PLVLiveViewController {
    NSString *socketid;
    NSTimer *timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initLivePreview];     // 初始化直播界面及推流器
    [self initChatRoom];        // 添加聊天室
    [self configDanmu];         // 初始化弹幕
}


- (void)initLivePreview {
    
    CGRect viewFrame;
    if (self.supportedInterfaceOrientation==UIInterfaceOrientationPortrait) {
        viewFrame = self.view.bounds;
    }else {
        viewFrame = CGRectMake(0, 0, HEIGHT, WIDTH);
    }
    
    self.livePreview = [[PLVLivePreview alloc] initWithFrame:viewFrame];
    self.livePreview.supportedInterfaceOrientation = self.supportedInterfaceOrientation;
    //livePreview.audioQuality = self.audioQuality;
    self.livePreview.videoQuality = self.videoQuality;
    
    [self.view addSubview:self.livePreview];
}

-(void)initChatRoom {
  
    [PLVChatRequest getChatTokenSuccess:^(NSString *chatToken) {
        NSLog(@"chat token is %@", chatToken);
        @try {
            _chatSocket = [[PLVChatSocket alloc] initChatSocketWithConnectParams:@{@"token":chatToken} enableLog:NO];
            _chatSocket.delegate = self;
            [_chatSocket connect];
        } @catch (NSException *exception) {
            NSLog(@"chat connect failed, reason:%@",exception.reason);
        }
    } failure:^(NSString *errorName, NSString *errorDescription) {
        NSLog(@"errorName: %@, errorDescription: %@",errorName,errorDescription);
    }];
}

- (void)configDanmu {
    
    CGRect bounds = self.livePreview.bounds;
    self.danmuLayer = [[ZJZDanMu alloc] initWithFrame:CGRectMake(0, 20, bounds.size.width, bounds.size.height-20)];
    [self.livePreview insertSubview:self.danmuLayer atIndex:0];
}


#pragma mark - chatSocket delegate 事件

/** socket成功连接上聊天室*/
- (void)socketIODidConnect:(PLVChatSocket *)chatSocket {
    NSLog(@"socket connected");
    socketid = chatSocket.scoketId;
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(onTime_tick) userInfo:nil repeats:YES];
    
    NSDictionary *userInfo = [PLVChannel sharedPLVChannel].userInfo;
    // 使用时间戳生成一个userId
    long long ts =(long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    NSString *userId = [NSString stringWithFormat:@"%lld",ts];
    // 登录聊天室
    [chatSocket loginStreamerChatRoomWithChannelId:userInfo[@"channelId"] userId:userId nickName:@"主持人" avatar:userInfo[@"avatar"]];
}

/** socket收到聊天室信息*/
- (void)socketIODidReceiveMessage:(PLVChatSocket *)chatSocket {
    
    PLVChatObject *chatObject = chatSocket.chatObject;
    NSLog(@"messageType: %ld",chatObject.messageType);
    
    switch (chatObject.messageType) {
        case PLVChatMessageTypeCloseRoom:
        case PLVChatMessageTypeOpenRoom: {
            NSLog(@"房间暂时关闭/打开");
        }
            break;
        case PLVChatMessageTypeGongGao: {
            NSLog(@"GongGao: %@",chatObject.messageContent);
            if (self.danmuLayer) {
                [self.danmuLayer insertDML:[@"公告：" stringByAppendingString:chatObject.messageContent]];           // 发送弹幕
            }
        }
            break;
        case PLVChatMessageTypeSpeak: {
            NSLog(@"messageContent: %@",chatObject.messageContent);
            if (chatObject.messageContent && ![chatObject.messageContent isKindOfClass:[NSNull class]]) {
                if (self.danmuLayer) {
                    [self.danmuLayer insertDML:chatObject.messageContent];                                          // 发送弹幕
                }
            }
        }
            break;
        case PLVChatMessageTypeError:
            break;
        default:
            break;
    }
}

/** socket和聊天室失去连接*/
- (void)socketIODidDisconnect:(PLVChatSocket *)chatSocket {
    NSLog(@"socket error");
}

/** socket连接聊天室出错*/
- (void)socketIOConnectOnError:(PLVChatSocket *)chatSocket {
    NSLog(@"socket disconnect");
}

/** socket尝试重新连接聊天室时*/
- (void)socketIOReconnect:(PLVChatSocket *)chatSocket {
    NSLog(@"socket reconnect");
}

/** 当socket连接开始重新连接聊天室*/
- (void)socketIOReconnectAttempt:(PLVChatSocket *)chatSocket {
    NSLog(@"socket reconnectAttempt");
}



#pragma mark - 转屏相关

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {

    if (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTime_tick {
    // 每分钟刷新次聊天室后台，防止被kill掉连接
    [PLVChatRequest requestWithSocketId:socketid failure:^(NSInteger responseCode, NSString *errorReason) {
        NSLog(@"responseCode:%ld",responseCode);
    }];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (timer) {
        [timer invalidate];                 // 清除定时器
        timer = nil;
    }
    [self.chatSocket disconnect];           // 断开聊天室
    [self.chatSocket removeAllHandlers];    // 移除所有监听事件
    
    [super dismissViewControllerAnimated:flag completion:completion];
}

-(void)dealloc {
    DLog()
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
