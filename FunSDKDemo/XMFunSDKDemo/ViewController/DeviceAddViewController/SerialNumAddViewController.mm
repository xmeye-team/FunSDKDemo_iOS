//
//  SerialNumAddViewController.m
//  FunSDKDemo
//
//  Created by wujiangbo on 2018/11/12.
//  Copyright © 2018年 wujiangbo. All rights reserved.
//

#import "SerialNumAddViewController.h"
#import "AddDeviceInputCell.h"
#import <Masonry/Masonry.h>
#import "OriginalScaner.h"
#import "DeviceManager.h"
#import "MyStringManager.h"

@interface SerialNumAddViewController ()<UITableViewDelegate,UITableViewDataSource,DeviceManagerDelegate>
{
    NSArray *titleArray;                //列表数组
    DeviceManager *deviceManager;       //设备管理器
    UITextField *devNameTF;             //设备名
    UITextField *loginNameTF;           //登录名
    UITextField *devPswTF;              //设备密码
    UITextField *devSerialTF;           //设备序列号
}
@property (nonatomic,strong)UITableView *listTableView;         //输入列表
@property (nonatomic,strong)UIButton *addBtn;                   //添加按钮
@end

@implementation SerialNumAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //设备管理器
    deviceManager = [[DeviceManager alloc] init];
    deviceManager.delegate = self;
    //设置导航栏
    [self setNaviStyle];
    //初始化数据
    [self initDataSource];
    [self.view addSubview:self.listTableView];
    [self.view addSubview:self.addBtn];
    
    //控件布局
    [self configSubView];
}

- (void)setNaviStyle {
    self.navigationItem.title = TS("add_by_serialNumber");
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"new_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    self.navigationItem.leftBarButtonItem = leftBtn;
}

#pragma mark - 控件布局
-(void)configSubView{
    [self.listTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@110);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.9);
        make.height.equalTo(@200);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.listTableView.mas_bottom).offset(50);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.9);
        make.height.equalTo(@45);
        make.centerX.equalTo(self.view);
    }];
}

#pragma mark - button event
-(void)popViewController{
    if([SVProgressHUD isVisible]){
        [SVProgressHUD dismiss];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 点击空白处关闭键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark 通过序列号添加设备
-(void)addBtnClicked{
    // 先判断信息是否填写完整
    if (devNameTF.text.length == 0 || devSerialTF.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:TS("Info_Error1")];
        return;
    }
    enum STR_TYPE curType;
    curType = [MyStringManager getStrType:devSerialTF.text];
    if (curType != STR_TYPE_SN) {
        [SVProgressHUD showErrorWithStatus:TS("EE_CLOUD_PARAM_INVALID")];
        return;
    }
    [SVProgressHUD show];
    //通过序列号添加
    [deviceManager addDeviceByDeviseSerialnumber:devSerialTF.text deviceName:devNameTF.text devType:0];
    //修改设备名称和设备密码
    [deviceManager changeDevicePsw:devSerialTF.text loginName:loginNameTF.text password:devPswTF.text];
}

#pragma mark 点击二维码扫描
-(void)codeBtnClick{
    OriginalScaner *scaner = [[OriginalScaner alloc] init];
    scaner.myScanerFinishedBlock = ^(NSString *code){
        NSArray* arrayInfo = [deviceManager decodeDevInfo:code];
        
        //根据扫描二维码结果显示设备名和设备序列号
        devNameTF.text = arrayInfo[0];
        devSerialTF.text = arrayInfo[0];
    };
    
     [self.navigationController pushViewController:scaner animated:NO];
}

#pragma mark - tableViewDataSource/Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddDeviceInputCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddDeviceInputCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *titleStr = titleArray[indexPath.row];
    
    cell.customTitle.text = titleStr;
    
    if ([titleStr isEqualToString:TS("Device_Name")]) {
        cell.inputTextField.attributedPlaceholder =
        [[NSAttributedString alloc]initWithString:TS("Enter_Device_Name") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        devNameTF = cell.inputTextField;
    }
    else if ([titleStr isEqualToString:TS("serial_number")]){
        cell.inputTextField.attributedPlaceholder =
        [[NSAttributedString alloc]initWithString:TS("Enter_serial_number") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        devSerialTF = cell.inputTextField;
        //添加扫描二维码按钮
        if (!cell.codeBtn) {
            cell.codeBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth* 0.9 - 40, 10, 30, 30)];
            [cell.codeBtn setImage:[UIImage imageNamed:@"QRCode.png"] forState:UIControlStateNormal];
            [cell.codeBtn addTarget:self action:@selector(codeBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:cell.codeBtn];
        }
    }
    else if ([titleStr isEqualToString:TS("UserName")]){
        cell.inputTextField.attributedPlaceholder =
        [[NSAttributedString alloc]initWithString:TS("Enter_LoginName") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        cell.inputTextField.text = @"admin";
        cell.inputTextField.enabled = NO;
        loginNameTF = cell.inputTextField;
    }
    else if ([titleStr isEqualToString:TS("Password2")]){
        cell.inputTextField.attributedPlaceholder =
        [[NSAttributedString alloc]initWithString:TS("Enter_LoginPassword") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
        devPswTF = cell.inputTextField;
    }
    
    return cell;
}

#pragma mark - funsdk 回调处理
- (void)addDeviceResult:(int)result{
}

#pragma mark - 界面和数据初始化
- (void)initDataSource {
    titleArray = @[TS("Device_Name"),TS("serial_number"),TS("UserName"),TS("Password2")];
}

-(UITableView *)listTableView{
    if (!_listTableView) {
        _listTableView = [[UITableView alloc] init];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.scrollEnabled = NO;
        [_listTableView registerClass:[AddDeviceInputCell class] forCellReuseIdentifier:@"AddDeviceInputCell"];
    }
    
    return _listTableView;
}

-(UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [[UIButton alloc] init];
        [_addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_addBtn setTitle:TS("OK") forState:UIControlStateNormal];
        [_addBtn setBackgroundColor:GlobalMainColor];
    }
    
    return _addBtn;
}

@end
