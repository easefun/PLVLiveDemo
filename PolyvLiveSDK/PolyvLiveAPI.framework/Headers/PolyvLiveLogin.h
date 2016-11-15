//
//  PolyvLiveLogin.h
//  PLVLiveDemo
//
//  Created by ftao on 2016/11/14.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PolyvLiveLogin : NSObject


/**
 *  使用保利威视直播接口获取推流的相关信息
 *
 *  @param channelId 登录直播的频道号或子频道号
 *  @param password  登录直播频道号的密码
 *  @param success   登录成功的回调信息（推流地址和流名）
 *  @param failure   登录失败的回调信息（如频道账号密码错误、网络请求失败等）
 */
+ (void)loginWithChannelId:(NSString *)channelId
                  password:(NSString *)password
                   success:(void(^)(NSString *rtmpUrl, NSString *streamName))success
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
