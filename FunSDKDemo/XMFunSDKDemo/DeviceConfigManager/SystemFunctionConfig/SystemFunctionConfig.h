//
//  SystemFunctionConfig.h
//  FunSDKDemo
//
//  Created by XM on 2018/5/8.
//  Copyright © 2018年 XM. All rights reserved.
//
/***
 
 获取设备各种通用能力级 SystemFunction
 
*****/

@protocol SystemFunctionConfigDelegate <NSObject>
//获取能力级回调信息
- (void)SystemFunctionConfigGetResult:(BOOL)result;
@end

#import "ConfigControllerBase.h"

@interface SystemFunctionConfig : ConfigControllerBase

@property (nonatomic, assign) id <SystemFunctionConfigDelegate> delegate;

#pragma mark - 通过设备序列号获取设备各种能力级
- (void)getSystemFunction:(NSString *)deviceMac;
@end
