//
//  PLVRtmpSetting.h
//  PLVLiveDemo
//
//  Created by ftao on 2019/3/28.
//  Copyright © 2019 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PLVLiveKit/LFLiveKit.h>
#import <PLVLiveAPI/PLVPushChannel.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PLVRTMP_SDK_VERSION;

typedef NS_ENUM(NSUInteger, PLVRtmpDefinition) {
    /// 标清
    PLVRtmpDefinitionStandard,
    /// 高清
    PLVRtmpDefinitionHigh,
    /// 超清
    PLVRtmpDefinitionUltra,
};

@interface PLVRtmpSetting : NSObject

/// 推流地址
@property (nonatomic, strong, readonly) NSString *rtmpUrl;
/// 推流频道信息
@property (nonatomic, strong, readonly) PLVPushChannel *pushChannel;

/// 应用Id
@property (nonatomic, strong, readonly) NSString *appId;
/// 应用Secret
@property (nonatomic, strong, readonly) NSString *appSecret;

/// 推流清晰度
@property (nonatomic, assign) PLVRtmpDefinition definition;
/// 推流屏幕方向
@property (nonatomic, assign) BOOL landscapeMode;
/// 推流视频配置
@property (nonatomic, strong, readonly) LFLiveVideoConfiguration *videoConfig;
/// 推流音频配置
@property (nonatomic, strong, readonly) LFLiveAudioConfiguration *audioConfig;


/// 频道号（主账号id）
@property (nonatomic, strong, readonly) NSString *channelId;
/// 当前账号（主账号或子账号id）
@property (nonatomic, strong, readonly) NSString *accountId;
/// 子账号信息列表(key: accountId value:accountName)
@property (nonatomic, strong, readonly) NSDictionary *channelAccountList;
/// 是否主账号推流
@property (nonatomic, getter=isMasterAccount) BOOL masterAccount;
/// 最大码率(kbps)
@property (nonatomic, assign, readonly) NSUInteger maxRate;


/**
 便利初始化
 */
+ (instancetype)sharedRtmpSetting;

/**
 便利初始化

 @param channel 推流频道信息
 @param url 推流地址
 */
+ (instancetype)rtmpSettingWithPushChannel:(PLVPushChannel *)channel rtmpUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
