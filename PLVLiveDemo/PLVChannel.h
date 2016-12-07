//
//  PLVChannel.h
//  PLVLiveDemo
//
//  Created by ftao on 2016/12/7.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVChannel : NSObject

@property (nonatomic, copy) NSString *channelId;    // 频道号

@property (nonatomic, copy) NSString *rtmpUrl;      // 推流地址

@property (nonatomic, copy) NSString *streamName;   // 推流名

// 获取PLVChannel单例
+ (instancetype)sharedPLVChannel;

@end
