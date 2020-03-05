//
//  PLVRtmpSetting.m
//  PLVLiveDemo
//
//  Created by ftao on 2019/3/28.
//  Copyright © 2019 easefun. All rights reserved.
//

#import "PLVRtmpSetting.h"

/*
 v2.2.1+190726
 */

NSString *const PLVRTMP_SDK_VERSION = @"PolyvRtmpiOSSDK_v2.2.2+200305";

static PLVRtmpSetting *rtmpSetting = nil;

@interface PLVRtmpSetting ()

@property (nonatomic, strong) NSString *rtmpUrl;
@property (nonatomic, strong) PLVPushChannel *pushChannel;

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appSecret;

@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *accountId;
@property (nonatomic, strong) NSDictionary *channelAccountList;

@property (nonatomic, assign) NSUInteger maxRate;

@end

@implementation PLVRtmpSetting


+ (instancetype)sharedRtmpSetting {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rtmpSetting = [[PLVRtmpSetting alloc] init];
    });
    return rtmpSetting;
}

+ (instancetype)rtmpSettingWithPushChannel:(PLVPushChannel *)channel rtmpUrl:(NSString *)url {
    PLVRtmpSetting *setting = [PLVRtmpSetting sharedRtmpSetting];
    setting.pushChannel = channel;
    setting.rtmpUrl = url;
    
    NSDictionary *channelDict = channel.channelDict;
    if (channelDict) {
        setting.appId = channelDict[@"appId"];
        setting.appSecret = channelDict[@"appSecret"];
        
        setting.channelId = [NSString stringWithFormat:@"%@",channelDict[@"channelId"]];
        setting.accountId = [NSString stringWithFormat:@"%@",channelDict[@"accountId"]];
        setting.maxRate = (NSUInteger)[[NSString stringWithFormat:@"%@",channelDict[@"maxRate"]] integerValue];
        if (setting.maxRate == 0) {
            setting.maxRate = 1000;
        } else if (setting.maxRate < 600) {
            setting.maxRate = 600;
        }
        
        NSArray *subAccounts = channelDict[@"channelAccountList"];
        NSMutableDictionary *mDict = [NSMutableDictionary new];
        for (NSDictionary *dict in subAccounts) {
            [mDict setObject:dict[@"accountName"] forKey:dict[@"accountId"]];
        }
        setting.channelAccountList = mDict;
    }
    
    return setting;
}

#pragma mark - Getter

- (LFLiveVideoConfiguration *)videoConfig {
    if (!self.pushChannel) {
        return nil;
    }
    LFLiveVideoConfiguration *videoConfig = [[LFLiveVideoConfiguration alloc] init];
    videoConfig.autorotate = YES;
    videoConfig.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    videoConfig.videoFrameRate = 25;
    videoConfig.videoMaxKeyframeInterval = 50;
    
    switch (self.definition) {
        case PLVRtmpDefinitionStandard: {
            videoConfig.videoBitRate = 600 * 1000;  // 0.6Mkps
            videoConfig.videoMinBitRate = 500 * 1000;
            videoConfig.videoMaxBitRate = 700 * 1000;
            videoConfig.sessionPreset = LFCaptureSessionPreset360x640;
            videoConfig.videoSize = self.landscapeMode ? CGSizeMake(640, 360) : CGSizeMake(360, 640);
        } break;
        case PLVRtmpDefinitionHigh: {
            videoConfig.videoBitRate = 1000 * 1000;  // 1Mkps
            videoConfig.videoMinBitRate = 900 * 1000;
            videoConfig.videoMaxBitRate = 1100 * 1000;
            videoConfig.sessionPreset = LFCaptureSessionPreset540x960;
            videoConfig.videoSize = self.landscapeMode ? CGSizeMake(960, 540) : CGSizeMake(540, 960);
        } break;
        case PLVRtmpDefinitionUltra: {
            videoConfig.videoBitRate = self.maxRate * 1000;
            videoConfig.videoMinBitRate = self.maxRate * 1000 - 150;
            videoConfig.videoMaxBitRate = self.maxRate * 1000 + 150;
            videoConfig.sessionPreset = LFCaptureSessionPreset720x1280;
            videoConfig.videoSize = self.landscapeMode ? CGSizeMake(1280, 720) : CGSizeMake(720, 1280);
        } break;
    }
    return videoConfig;
}

- (LFLiveAudioConfiguration *)audioConfig {
    if (!self.pushChannel) {
        return nil;
    }
    switch (self.definition) {
        case PLVRtmpDefinitionStandard:
            return [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_Low];
            break;
        case PLVRtmpDefinitionHigh:
            return [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_Medium];
            break;
        case PLVRtmpDefinitionUltra:
            return [LFLiveAudioConfiguration defaultConfigurationForQuality:LFLiveAudioQuality_High];
            break;
    }
}

- (BOOL)isMasterAccount {
    if (self.pushChannel) {
        return [self.accountId isEqualToString:self.channelId];
    } else {
        return YES;
    }
}

@end
