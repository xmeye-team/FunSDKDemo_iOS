//
//  SystemFunctionConfig.m
//  FunSDKDemo
//
//  Created by XM on 2018/5/8.
//  Copyright © 2018年 XM. All rights reserved.
//

#import "SystemFunctionConfig.h"
#import "SystemFunction.h"
@interface SystemFunctionConfig ()
{
    SystemFunction functionCfg;
}
@end

@implementation SystemFunctionConfig

#pragma mark - 1、通过设备序列号获取设备各种能力级
- (void)getSystemFunction:(NSString *)deviceMac {
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    CfgParam* paramfunctionCfg = [[CfgParam alloc] initWithName:[NSString stringWithUTF8String:functionCfg.Name()] andDevId:channel.deviceMac andChannel:-1 andConfig:&functionCfg andOnce:YES andSaveLocal:NO];//获取能力级
    [self AddConfig:paramfunctionCfg];
    [self GetConfig:[NSString stringWithUTF8String:functionCfg.Name()]];
}

#pragma mark - 3、
- (void)OnGetConfig:(CfgParam *)param {
    [super OnGetConfig:param];
    ChannelObject *channel = [[DeviceControl getInstance] getSelectChannel];
    DeviceObject *object  = [[DeviceControl getInstance] GetDeviceObjectBySN:channel.deviceMac];
    if ([param.name isEqualToString:[NSString stringWithUTF8String:functionCfg.Name()]]) {
        //是否支持智能分析
        if (functionCfg.mAlarmFunction.VideoAnalyze.Value() == YES) {//老的智能分析
            object.sysFunction.NewVideoAnalyze = functionCfg.mAlarmFunction.NewVideoAnalyze.Value();
        }
        if (functionCfg.mAlarmFunction.NewVideoAnalyze.Value() == YES) {//新的智能分析
            object.sysFunction.NewVideoAnalyze = functionCfg.mAlarmFunction.NewVideoAnalyze.Value();
        }
        //是否支持智能快放
        if (functionCfg.mOtherFunction.SupportIntelligentPlayBack.Value() == YES) {
            object.sysFunction.SupportIntelligentPlayBack = functionCfg.mOtherFunction.SupportIntelligentPlayBack.Value();
        }
        //是否支持设置前端IP
        if (functionCfg.mOtherFunction.SupportSetDigIP.Value() == YES) {
            object.sysFunction.SupportSetDigIP = functionCfg.mOtherFunction.SupportSetDigIP.Value();
        }
        //是否支持433报警
        if (functionCfg.mAlarmFunction.Consumer433Alarm.Value() == YES) {
            object.sysFunction.IPConsumer433Alarm = functionCfg.mAlarmFunction.Consumer433Alarm.Value();
        }
        //获取能力级之后的结果回调
        if ([self.delegate respondsToSelector:@selector(SystemFunctionConfigGetResult:)]) {
            [self.delegate SystemFunctionConfigGetResult:param.errorCode];
        }
    }
}

#pragma mark - 2、请求SystemFunction回调
- (void)OnFunSDKResult:(NSNumber *)pParam {
    [super OnFunSDKResult:pParam];
}

@end
