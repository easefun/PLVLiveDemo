//
//  PLVChannel.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/12/7.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVChannel.h"

@implementation PLVChannel

+ (instancetype)sharedPLVChannel
{
    static PLVChannel *sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(void) {
        sharedSingleton = [[self alloc] initialize];
    });
    return sharedSingleton;
}

- (id)initialize
{
    if(self == [super init] )
    {
        _channelId = [NSString new];
        _rtmpUrl = [NSString new];
        _streamName = [NSString new];
    } 
    return self; 
}

@end
