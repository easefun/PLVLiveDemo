//
//  SettingTableViewController.h
//  PolyvStreamerDemo
//
//  Created by FT on 16/3/25.
//  Copyright © 2016年 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewController : UITableViewController


@property(nonatomic, assign)CGSize videoSize;   //视频分辨率

@property(nonatomic, assign)int frameRate;      //视频帧率

@property(nonatomic, assign)int bitrate;        //视频码率

//用于改变分辨率，帧率和视频码率的回调函数
@property(nonatomic,strong)void (^settingBlock)(CGSize,int,int);


@end
