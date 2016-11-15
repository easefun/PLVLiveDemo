//
//  PLVLiveViewController.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVLiveViewController.h"

@interface PLVLiveViewController ()

@end

@implementation PLVLiveViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    CGRect viewFrame;
    if (self.supportedInterfaceOrientation==UIInterfaceOrientationPortrait) {
        viewFrame = self.view.bounds;
    }else {
        viewFrame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
    }
    
    PLVLivePreview *livePreview = [[PLVLivePreview alloc] initWithFrame:viewFrame];
    livePreview.rtmpUrl = self.rtmpUrl;
    livePreview.supportedInterfaceOrientation = self.supportedInterfaceOrientation;
    livePreview.audioQuality = self.audioQuality;
    livePreview.videoQuality = self.videoQuality;
    
    [self.view addSubview:livePreview];
    
    //[self.view addSubview:[[PLVLivePreview alloc] initWithFrame:self.view.bounds]];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {

    if (_supportedInterfaceOrientation==UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    NSLog(@"");
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
