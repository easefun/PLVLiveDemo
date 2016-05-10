//
//  CameraViewController.h
//  PolyvStreamerDemo
//
//  Created by FT on 16/3/17.
//  Copyright © 2016年 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (weak, nonatomic) IBOutlet UIButton *streamButton;

@property (weak, nonatomic) IBOutlet UIButton *settingButton;


@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (strong, nonatomic) IBOutlet UIView *stateView;



@end
