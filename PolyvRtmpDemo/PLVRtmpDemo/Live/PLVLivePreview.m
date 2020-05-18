//
//  PLVLivePreview.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVLivePreview.h"
#import "UIView+YYAdd.h"

@interface PLVLivePreview ()

@property (nonatomic, strong) UIView *containerView;

@end

@implementation PLVLivePreview

- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.containerView];
        
        [self.containerView addSubview:self.stateLabel];
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.cameraButton];
        [self.containerView addSubview:self.beautyButton];
        [self.containerView addSubview:self.waterMarkButton];
        [self.containerView addSubview:self.rateLabel];
        [self.containerView addSubview:self.startLiveButton];
    }
    return self;
}

#pragma mark - Public

- (void)liveState {
    self.startLiveButton.enabled = NO;
    [self.startLiveButton setTitle:@"直播中" forState:UIControlStateNormal];
    [self.startLiveButton setBackgroundColor:[UIColor redColor]];
}

- (void)stopState {
    self.rateLabel.text = @"0KB/s";
    self.startLiveButton.enabled = YES;
    [self.startLiveButton setTitle:@"未直播" forState:UIControlStateNormal];
    [self.startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
}

#pragma mark - Actions

- (void)beautyButton:(UIButton *)sender {
    if ([self.deleagte respondsToSelector:@selector(livePreview:didBeautyButtonClicked:)]) {
        [self.deleagte livePreview:self didBeautyButtonClicked:sender];
    }
}

- (void)cameraButton:(UIButton *)sender {
    if ([self.deleagte respondsToSelector:@selector(livePreview:didCameraButtonClicked:)]) {
        [self.deleagte livePreview:self didCameraButtonClicked:sender];
    }
}

- (void)waterMarkButton:(UIButton *)sender {
    if ([self.deleagte respondsToSelector:@selector(livePreview:didWaterMarkButtonClicked:)]) {
        [self.deleagte livePreview:self didWaterMarkButtonClicked:sender];
    }
}

- (void)startLiveButton:(UIButton *)sender {
    if ([self.deleagte respondsToSelector:@selector(livePreview:didStartLiveButtonClicked:)]) {
        [self.deleagte livePreview:self didStartLiveButtonClicked:sender];
    }
}

- (void)closeButton:(UIButton *)sender {
  if ([self.deleagte respondsToSelector:@selector(livePreview:didCloseButtonClicked:)]) {
        [self.deleagte livePreview:self didCloseButtonClicked:sender];
    }
}

#pragma mark - Getter

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.frame = self.bounds;
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _containerView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 80, 40)];
        _stateLabel.text = @"未连接";
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
    }
    return _stateLabel;
}

- (UILabel *)rateLabel {
    if (!_rateLabel) {
        _rateLabel = [UILabel new];
        _rateLabel.size = CGSizeMake(70, 25);
        _rateLabel.top = _closeButton.bottom + 10;
        _rateLabel.right = _closeButton.right - 5;
        _rateLabel.text = @"0KB/s";
        _rateLabel.textColor = [UIColor whiteColor];
        _rateLabel.font = [UIFont boldSystemFontOfSize:12.f];
        _rateLabel.textAlignment = NSTextAlignmentRight;
        _rateLabel.adjustsFontSizeToFitWidth = YES;
        _rateLabel.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        _rateLabel.layer.cornerRadius = 8.0;
        _rateLabel.layer.masksToBounds = YES;
    }
    return _rateLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton new];
        _closeButton.size = CGSizeMake(44, 44);
        _closeButton.left = self.width - 10 - _closeButton.width;
        _closeButton.top = 20;
        [_closeButton setImage:[UIImage imageNamed:@"plv_close"] forState:UIControlStateNormal];
        _closeButton.exclusiveTouch = YES;
        [_closeButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton new];
        _cameraButton.size = CGSizeMake(44, 44);
        _cameraButton.origin = CGPointMake(_closeButton.left - 10 - _cameraButton.width, 20);
        [_cameraButton setImage:[UIImage imageNamed:@"plv_camera"] forState:UIControlStateNormal];
        _cameraButton.exclusiveTouch = YES;
        [_cameraButton addTarget:self action:@selector(cameraButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)beautyButton {
    if (!_beautyButton) {
        _beautyButton = [UIButton new];
        _beautyButton.size = CGSizeMake(44, 44);
        _beautyButton.origin = CGPointMake(_cameraButton.left - 10 - _beautyButton.width, 20);
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty"] forState:UIControlStateNormal];
        [_beautyButton setImage:[UIImage imageNamed:@"camra_beauty_close"] forState:UIControlStateSelected];
        _beautyButton.exclusiveTouch = YES;
        [_beautyButton addTarget:self action:@selector(beautyButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyButton;
}

- (UIButton *)waterMarkButton {
    if (!_waterMarkButton) {
        _waterMarkButton = [UIButton new];
        _waterMarkButton.size = CGSizeMake(44, 44);
        _waterMarkButton.origin = CGPointMake(_beautyButton.left - 10 - _waterMarkButton.width , 20);
        [_waterMarkButton setImage:[UIImage imageNamed:@"plv_watermark_close"] forState:UIControlStateNormal];
        [_waterMarkButton setImage:[UIImage imageNamed:@"plv_watermark"] forState:UIControlStateSelected];
        [_waterMarkButton addTarget:self action:@selector(waterMarkButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _waterMarkButton;
}

- (UIButton *)startLiveButton {
    if (!_startLiveButton) {
        _startLiveButton = [UIButton new];
        _startLiveButton.size = CGSizeMake(self.width / 2, 44);
        _startLiveButton.centerX = self.centerX;
        _startLiveButton.bottom = self.height - 50;
        _startLiveButton.layer.cornerRadius = _startLiveButton.height/2;
        [_startLiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startLiveButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startLiveButton setBackgroundColor:[UIColor colorWithRed:50 green:32 blue:245 alpha:1]];
        _startLiveButton.exclusiveTouch = YES;
        [_startLiveButton addTarget:self action:@selector(startLiveButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startLiveButton;
}

@end

