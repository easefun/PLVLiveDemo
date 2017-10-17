//
//  PLVStreamerLogin.h
//  PLVLiveAPI
//
//  Created by ftao on 2017/4/18.
//  Copyright © 2017年 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVStreamerLogin : NSObject

/**
 *  通知服务器推流模式为单流模式（如该频道之前推流过PPt和视频双流，此时需要主动通知服务器切回单视频流模式）
 *
 *  @param channelId    设置单流模式的直播频道号或子频道号
 *  @param stream       设置单流模式当前直播的流名
 *  @param success      设置单流模式成功的回调（返回sessionId）
 *  @param failure      设置单流模式失败的回调（网络请求失败、响应码非200等）
 */
+ (void)configAloneStreamModeWithChannelId:(NSString *)channelId
                                    stream:(NSString *)stream
                                   success:(void (^)(NSString *responseBody))success
                                   failure:(void (^)(NSString *failure))failure;

/**
 *  使用保利威视直播频道号和密码获取推流地址
 *
 *  @param channelId 直播频道号或子频道号
 *  @param password  直播频道号的密码
 *  @param success   成功获取推流地址、流名和用户信息的回调(推流地址不需要再次拼接)
 *  @param failure   推流地址获取失败的回调（频道号或密码错误、网络请求失败、响应码非200等）
 */
+ (void)loginWithChannelId:(NSString *)channelId
                  password:(NSString *)password
                   success:(void(^)(NSString *rtmpUrl, NSString *streamName, NSDictionary *userInfo))success
                   failure:(void(^)(NSString *errName, NSString *errReason))failure;

/**
 * 当前流是否正在直播(此方法为同步线程)
 *
 * @param steameName 直播流名
 *
 * @return -1代表请求失败或网络错误；0代表未在直播；1代表正在直播；-2代表返回状态未知
 */
+ (int)isLiveWithStreameName:(NSString *)steameName;

@end
