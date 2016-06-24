//
//  SettingTableViewController.h
//  PolyvStreamerDemo
//
//  Created by ftao on 16/3/25.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingController : UITableViewController


@property(nonatomic, assign)CGSize videoSize;                       // 视频分辨率
@property(nonatomic, assign)int frameRate;                          // 视频帧率
@property(nonatomic, assign)int bitrate;                            // 视频码率
@property(nonatomic,strong)void (^settingBlock)(CGSize,int,int);    // 改变分辨率,帧率和码率的回调


@end
