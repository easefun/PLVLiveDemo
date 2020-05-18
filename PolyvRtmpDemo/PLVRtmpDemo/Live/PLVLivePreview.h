//
//  PLVLivePreview.h
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLVLivePreview;

@protocol PLVLivePreviewDelegate <NSObject>

- (void)livePreview:(PLVLivePreview *)livePreview didBeautyButtonClicked:(UIButton *)sender;
- (void)livePreview:(PLVLivePreview *)livePreview didCameraButtonClicked:(UIButton *)sender;
- (void)livePreview:(PLVLivePreview *)livePreview didWaterMarkButtonClicked:(UIButton *)sender;
- (void)livePreview:(PLVLivePreview *)livePreview didStartLiveButtonClicked:(UIButton *)sender;
- (void)livePreview:(PLVLivePreview *)livePreview didCloseButtonClicked:(UIButton *)sender;

@end

@interface PLVLivePreview : UIView

@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *rateLabel;

@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *waterMarkButton;
@property (nonatomic, strong) UIButton *startLiveButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, weak) id<PLVLivePreviewDelegate> deleagte;

- (void)liveState;

- (void)stopState;

@end
