//
//  SettingViewController.m
//  PLVLiveDemo
//
//  Created by ftao on 2016/10/31.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "SettingViewController.h"
#import "PLVLiveViewController.h"

@interface SettingViewController ()

@property (nonatomic, copy) NSArray *rtmpModeArr;
@property (nonatomic, copy) NSArray *audioQualityArr;
@property (nonatomic, copy) NSArray *videoQualityArr;

@property (nonatomic, copy) NSArray *videoQualityDetailArr;

@property (nonatomic, assign) NSInteger selectedRtmpModeRow;
@property (nonatomic, assign) NSInteger selectedVideoQualityRow;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"推流设置";
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStyleDone target:self action:@selector(logOutButtonClick)];

    // 删除 preview中的接口   设置非detail的宽度
    
    // 配置数据源
    self.rtmpModeArr = @[@"竖屏模式",@"横屏模式"];
    self.videoQualityArr = @[@"240p(弱网)",@"360p(流畅)",@"540p(普通)",@"540p(普通)",@"720p(高清)",@"720p(高清)"];
    self.videoQualityDetailArr = @[@"15 240Kbps 64Kbps",@"15 400Kbps 96Kbps",@"15 600Kbps 96Kbps(默认)",@"20 800Kbps 96Kbps",@"15 900Kbps 96Kbps",@"20 1200Kbps 128Kbps"];    // 这里视频码率实际稍大一些，设置中为*1024非*1000
    
    // 设置默认值
    self.selectedRtmpModeRow = 1;
    self.selectedVideoQualityRow = 2;

    // 添加底部按钮
    [self addTableFooterButton];
}

- (void)addTableFooterButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 100, 20, 44);
    [button setTitle:@"进入直播" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 10.0;
    button.layer.borderWidth = 1.0;
    button.backgroundColor = [UIColor greenColor];
    [button addTarget:self action:@selector(enterLiveController) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = button;
}

- (void)enterLiveController {

    PLVLiveViewController *liveViewController = [PLVLiveViewController new];
    liveViewController.rtmpUrl = self.rtmpUrl;
    liveViewController.supportedInterfaceOrientation = _selectedRtmpModeRow ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
    liveViewController.videoQuality = _selectedVideoQualityRow;
    
    [self presentViewController:liveViewController animated:YES completion:nil];
}

- (void)logOutButtonClick {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView Data Source Delegate

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
    
    if (indexPath.section==0) {
        cell.textLabel.text = _rtmpModeArr[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.text = indexPath.row ? @"(默认)" : @"";
        cell.accessoryType = (indexPath.row == _selectedRtmpModeRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }else {
        cell.textLabel.text = _videoQualityArr[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.text = _videoQualityDetailArr[indexPath.row];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.accessoryType = (indexPath.row == _selectedVideoQualityRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; // 取消选择时的灰色阴影效果
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];   // 取消当前选中状态
    
    if (indexPath.section==0 && indexPath.row!=_selectedRtmpModeRow) {
        
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];   // 标记当前选中的cell
    
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_selectedRtmpModeRow inSection:0];
        _selectedRtmpModeRow = indexPath.row;
        [[tableView cellForRowAtIndexPath:lastIndexPath] setAccessoryType:UITableViewCellAccessoryNone];    // 取消上次选中的cell
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
    if (section==0) {
        headView.textLabel.text = @"推流模式";
    }else {
        headView.textLabel.text = @"推流参数(帧数 视频码率 音频码率)";
    }
    return headView;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
