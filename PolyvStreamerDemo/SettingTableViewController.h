//
//  SettingTableViewController.h
//  PolyvStreamerDemo
//
//  Created by FT on 16/3/25.
//  Copyright © 2016年 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewController : UITableViewController


@property(nonatomic, assign)CGSize videoSize;

@property(nonatomic, assign)int frameRate;

@property(nonatomic, assign)int bitrate;

//用于改变分辨率，帧率和视频码率的回调函数
@property(nonatomic,strong)void (^settingBlock)(CGSize,int,int);


@end
