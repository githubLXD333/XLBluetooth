//
//  XLCentralManager.h
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/12.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLSpeaker.h"
#import "XLBleOptios.h"

@interface XLCentralManager : NSObject
{
@public
    // 中心管理者(管理设备的扫描和连接)
    CBCentralManager *centralManager;
    XLSpeaker *xlSpeaker; // 回叫方法
}

@property (nonatomic, strong) XLBleOptios *xlBleOptios; // 初始化参数
/**
 | 扫描设备并自动连接写入数据
 */
- (void)scanPeripheral;

/**
 | 连接指定的设备
 */
- (void)connectToPeripheral:(CBPeripheral *)peripheral;

/**
 | 断开指定的设备
 */
- (void)disconnectToPeripheral:(CBPeripheral *)peripheral;

/**
 | 获取所有以前连接成功过的设备
 */
- (void)getHistoryPeripherals;

/**
 | 停止扫描
 */
- (void)stopScan;
@end
