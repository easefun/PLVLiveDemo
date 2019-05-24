//
//  SettingViewController.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVSettingViewController.h"
#import "PLVLiveViewController.h"
#import "PLVAuthorizationManager.h"

@interface PLVSettingViewController ()

@property (nonatomic, copy) NSArray *rtmpModeArr;
@property (nonatomic, copy) NSArray *audioQualityArr;
@property (nonatomic, copy) NSArray *videoQualityArr;

@property (nonatomic, copy) NSArray *videoQualityDetailArr;

@property (nonatomic, assign) NSInteger selectedRtmpModeRow;
@property (nonatomic, assign) NSInteger selectedVideoQualityRow;

@end

@implementation PLVSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
    self.selectedRtmpModeRow = 1;
    self.selectedVideoQualityRow = 1;
    
    self.rtmpModeArr = @[@"竖屏模式",@"横屏模式"];
    self.videoQualityArr = @[@"360p(标清)",@"540p(高清)",@"720p(超清)"];
    self.videoQualityDetailArr = @[@"25 600Kbps 64Kbps",@"25 1000Kbps 96Kbps(默认)",@"25 --Kbps 128Kbps"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLable.text = @"直播设置";
    titleLable.textColor = [UIColor whiteColor];
    titleLable.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLable;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStyleDone target:self action:@selector(logoutButtonBeClicked)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(CGRectGetMidX(self.view.bounds)-150, 10, 300, 40);
    [button setTitle:@"进入直播" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 20.0;
    button.layer.masksToBounds = YES;
    button.backgroundColor = [UIColor colorWithRed:76/255.0 green:154/255.5 blue:1.0 alpha:1.0];
    [button addTarget:self action:@selector(enterLivePage) forControlEvents:UIControlEventTouchUpInside];

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 60)];
    [footerView addSubview:button];
    self.tableView.tableFooterView = footerView;
}

#pragma mark - Actions

- (void)logoutButtonBeClicked {
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)enterLivePage {
    __weak typeof(self) weakSelf = self;
    [PLVAuthorizationManager requestAuthorizationForAudioAndVideo:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                PLVRtmpSetting *setting = [PLVRtmpSetting sharedRtmpSetting];
                setting.definition = weakSelf.selectedVideoQualityRow;
                setting.landscapeMode = weakSelf.selectedRtmpModeRow == 1 ? YES : NO;
                [weakSelf presentViewController:[PLVLiveViewController new] animated:YES completion:nil];
            } else {
                [PLVAuthorizationManager showAlertWithTitle:nil message:@"直播需要获取您的摄像机及音频权限，前往设置" viewController:weakSelf];
            }
        });
    }];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return _rtmpModeArr.count;
    }else {
        return _videoQualityArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"identifier"];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = _rtmpModeArr[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.text = indexPath.row ? @"(默认)" : @"";
        cell.accessoryType = (indexPath.row == _selectedRtmpModeRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        cell.textLabel.text = _videoQualityArr[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.text = _videoQualityDetailArr[indexPath.row];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.accessoryType = (indexPath.row == _selectedVideoQualityRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section==0 && indexPath.row!=_selectedRtmpModeRow) {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_selectedRtmpModeRow inSection:0];
        _selectedRtmpModeRow = indexPath.row;
        [[tableView cellForRowAtIndexPath:lastIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
    }else if (indexPath.section==1  && indexPath.row!=_selectedVideoQualityRow){
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_selectedVideoQualityRow inSection:1];
        _selectedVideoQualityRow = indexPath.row;
        [[tableView cellForRowAtIndexPath:lastIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headView = [UITableViewHeaderFooterView new];
    if (section == 0) {
        headView.textLabel.text = @"推流模式";
    }else {
        headView.textLabel.text = @"推流参数(帧率 视频码率 音频码率)";
    }
    return headView;
}

#pragma mark - View Control

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

@end
