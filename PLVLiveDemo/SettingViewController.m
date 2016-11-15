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

@property (nonatomic, copy) NSArray *audioQualityDetailArr;
@property (nonatomic, copy) NSArray *videoQualityDetailArr;

@property (nonatomic, assign) NSInteger selectedRtmpModeRow;
@property (nonatomic, assign) NSInteger selectedAudioQualityRow;
@property (nonatomic, assign) NSInteger selectedVideoQualityRow;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"推流设置";
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStyleDone target:self action:@selector(logOutButtonClick)];

    
    // 配置数据源
    self.rtmpModeArr = @[@"竖屏模式",@"横屏模式"];
    self.audioQualityArr = @[@"低音频质量",@"中音频质量",@"高音频质量",@"超高音频质量"];
    self.videoQualityArr = @[@"低视频质量1",@"低视频质量2",@"中视频质量1",@"中视频质量2",@"高视频质量1",@"高视频质量2"];
    
    self.audioQualityDetailArr = @[@"16KHz 32Kbps(单)/64Kbps",@"44.1KHz 96Kbps",@"44.1KHz 128Kbps(默认)",@"48KHz 128Kbps"];
    self.videoQualityDetailArr = @[@"360*640 15 500Kps",@"360*640 20 650Kps",@"540*960 15 800Kps",@"540*960 20 800Kps(默认)",@"720*1280 15 1000Kps",@"720*1280 20 1200Kps"];
    
    // 设置默认值
    self.selectedRtmpModeRow = 0;
    self.selectedAudioQualityRow = 2;
    self.selectedVideoQualityRow = 3;

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
    liveViewController.audioQuality = _selectedAudioQualityRow;
    liveViewController.videoQuality = _selectedVideoQualityRow;
    
    [self presentViewController:liveViewController animated:YES completion:nil];
}

- (void)logOutButtonClick {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView Data Source Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return _rtmpModeArr.count;
    }else if (section==1) {
        return _audioQualityArr.count;
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
        cell.detailTextLabel.text = indexPath.row ? @"" : @"(默认)";
        cell.accessoryType = (indexPath.row == _selectedRtmpModeRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }else if (indexPath.section==1) {
        cell.textLabel.text = _audioQualityArr[indexPath.row];
        cell.detailTextLabel.text = _audioQualityDetailArr[indexPath.row];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        cell.accessoryType = (indexPath.row == _selectedAudioQualityRow) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }else {
        cell.textLabel.text = _videoQualityArr[indexPath.row];
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
    }else if (indexPath.section==1  && indexPath.row!=_selectedAudioQualityRow) {
        
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_selectedAudioQualityRow inSection:1];
        _selectedAudioQualityRow = indexPath.row;
        [[tableView cellForRowAtIndexPath:lastIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
    }else if (indexPath.section==2  && indexPath.row!=_selectedVideoQualityRow){
        
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_selectedVideoQualityRow inSection:2];
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
    }else if (section==1) {
        headView.textLabel.text = @"音频质量(参数:采样率 码率)";
    }else {
        headView.textLabel.text = @"视频质量(参数:分辨率 帧数 码率)";
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
