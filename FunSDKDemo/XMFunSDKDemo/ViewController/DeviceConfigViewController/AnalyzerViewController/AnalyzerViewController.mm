//
//  AnalyzerViewController.m
//  FunSDKDemo
//
//  Created by XM on 2018/12/22.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "AnalyzerViewController.h"
#import "ItemViewController.h"
#import "ItemTableviewCell.h"
#import "AnalyzeConfig.h"

@interface AnalyzerViewController () <UITableViewDelegate,UITableViewDataSource,AnalyzeConfigDelegate>
{
    AnalyzeConfig *config; //智能分析
    UITableView *analyzerTableView;
    NSMutableArray *analyzerTitleArray;
}
@end

@implementation AnalyzerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tableview数据
    [self initDataSource];
    [self configSubView];
    // 获取智能分析配置
    [self getVideoRotainConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    //有加载状态、则取消加载
    if ([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
}

#pragma mark - 获取智能分析配置
- (void)getVideoRotainConfig {
    [SVProgressHUD showWithStatus:TS("")];
    if (config == nil) {
        config = [[AnalyzeConfig alloc] init];
        config.delegate = self;
    }
    //调用获取智能分析等参数的接口
    [config getAnalyzeConfig];
}
#pragma mark 获取智能分析代理回调
- (void)getAnalyzeConfigResult:(NSInteger)result {
    if (result >0) {
        //成功，刷新界面数据
        [self.analyzerTableView reloadData];
        [SVProgressHUD dismiss];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - 保存智能分析配置 （
-(void)saveConfig{
    [SVProgressHUD show];
    [config setAnalyzeConfig];
}
#pragma mark 保存智能分析代理回调
- (void)setAnalyzeConfigResult:(NSInteger)result {
    if (result >0) {
        //成功
        [SVProgressHUD dismissWithSuccess:TS("Success")];
    }else{
        [MessageUI ShowErrorInt:(int)result];
    }
}

#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return analyzerTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
    if (!cell) {
        cell = [[ItemTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableviewCell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *title = [analyzerTitleArray objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    if ([config checkParam] == NO) {
        //当前配置参数无效，不能刷新
        return cell;
    }
    AnalyzeDataSource *dataSource = [config getAnalyzeDataSource];
    if ([title isEqualToString:TS("Analyzer_Enable")]) {
        if (dataSource.AnalyzeEnable == YES) {
            cell.Labeltext.text = TS("open");
        }else{
             cell.Labeltext.text = TS("close");
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([config checkParam] == NO) {
        return; //
    }
    NSString *titleStr = analyzerTitleArray[indexPath.row];
    //初始化各个配置的item单元格
    ItemViewController *itemVC = [[ItemViewController alloc] init];
    [itemVC setTitle:titleStr];
    
    __weak typeof(self) weakSelf = self;
    itemVC.itemSelectStringBlock = ^(NSString *encodeString) {
        //itemVC的单元格点击回调,设置各种属性
        ItemTableviewCell *cell = [weakSelf.analyzerTableView cellForRowAtIndexPath:indexPath];
        cell.Labeltext.text = encodeString;
        if ([cell.textLabel.text isEqualToString:TS("Analyzer_Enable")]) {
             AnalyzeDataSource *dataSource = [config getAnalyzeDataSource];
            if ([encodeString isEqualToString:TS("open")]) {
                dataSource.AnalyzeEnable = YES;
            }else if ([encodeString isEqualToString:TS("close")])
                 dataSource.AnalyzeEnable = NO;
        }else{
            return;
        }
    };
    //点击单元格之后进行分别赋值
    if ([titleStr isEqualToString:TS("Analyzer_Enable")]) {
        NSMutableArray *array = (NSMutableArray*)@[TS("open"),TS("close")];
        [itemVC setValueArray:array];
    }else{
        return;
    }
    //如果赋值成功，跳转到下一级界面
    [self.navigationController pushViewController:itemVC animated:YES];
}


#pragma mark - 界面和数据初始化
- (void)configSubView {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave  target:self action:@selector(saveConfig)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.view addSubview:self.analyzerTableView];
}
- (UITableView *)analyzerTableView {
    if (!analyzerTableView) {
        analyzerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight ) style:UITableViewStylePlain];
        analyzerTableView.delegate = self;
        analyzerTableView.dataSource = self;
        [analyzerTableView registerClass:[ItemTableviewCell class] forCellReuseIdentifier:@"ItemTableviewCell"];
    }
    return analyzerTableView;
}
#pragma mark - 界面和数据初始化
- (void)initDataSource {
    analyzerTitleArray = (NSMutableArray*)@[TS("Analyzer_Enable")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
