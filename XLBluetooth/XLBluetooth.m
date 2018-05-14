//
//  XLBluetooth.m
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/11.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import "XLBluetooth.h"
#import "XLSpeaker.h"
#import "XLBleOptios.h"
#import "XLCentralManager.h"

static XLBluetooth *share = nil;
static dispatch_once_t onceToken;

@implementation XLBluetooth
{
    XLCentralManager *xlCentralManager;
    XLSpeaker *xlSpeaker;
}

+ (instancetype)shareXLBluetooth {
    dispatch_once(&onceToken, ^{
        share = [[XLBluetooth alloc] init];
    });
    return share;
}

- (instancetype)init {
    if (self = [super init]) {
        xlCentralManager = [[XLCentralManager alloc] init];
        xlSpeaker = [[XLSpeaker alloc] init];
        xlCentralManager->xlSpeaker = xlSpeaker;
        XLBleOptios *xlBleOptios = [[XLBleOptios alloc] init];
        xlCentralManager.xlBleOptios = xlBleOptios;
    }
    return self;
}

+ (void)attempDealloc {
    onceToken = 0;
    share = nil;
}

#pragma mark - xlbluetooth的委托
/*
 默认频道的委托
 */
- (void)setBlockOnCentralManagerDidUpdateState:(void (^)(CBCentralManager *central))block { // 设备状态改变的委托
    [[xlSpeaker callback] setBlockOnCentralManagerDidUpdateState:block];
}

- (void)setBlockOnDiscoverToPeripherals:(void (^)(CBCentralManager *central, CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block { // 找到Peripherals的委托
    [[xlSpeaker callback] setBlockOnDiscoverPeripherals:block];
}

- (void)setBlockOnConnected:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress))block { //连接Peripherals成功的委托
    [xlSpeaker callback].blockOnConnectedPeripheral = block;
}

- (void)setBlockOnWrited:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress))block { //写入数据到Peripherals成功的委托
    [xlSpeaker callback].blockOnWritedPeripheral = block;
}

- (void)setBlockOnWritingData:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress))block { // 正在写入Peripherals数据的委托
    [xlSpeaker callback].blockOnWritingData = block;
}

- (void)setBlockOnWritingDataBreak:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress))block { // 正在写入Peripherals数据，中途断开的委托
    [xlSpeaker callback].blockOnWritingDataBreak = block;
}

- (void)setBlockOnDisConnected:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress))block { //断开Peripherals成功的委托
    [xlSpeaker callback].blockOnDisConnectedPeripheral = block;
}

// 连接Peripherals失败的委托
- (void)setBlockOnFailToConnect:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block {
    [[xlSpeaker callback] setBlockOnFailToConnect:block];
}

- (void)setBlockOnHistoryPeripherals:(void (^)(CBCentralManager *central, NSArray<CBPeripheral *> *peripherals, NSDictionary *macAddressDict))block { //获取以前连接过的Peripherals的委托
    [xlSpeaker callback].blockOnHistoryPeripherals = block;
}

- (XLBluetooth *(^)(NSString *macAddress, NSString *writeCharactData))scanForPeripheral { // 开始扫描peripheral
    return ^XLBluetooth *(NSString *macAddress, NSString *writeCharactData) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (CBCentralManagerStatePoweredOn == (xlCentralManager->centralManager.state)) { // 如果蓝牙已打开
                if (macAddress.length && ![macAddress isEqualToString:@"printer"]) {
                    xlCentralManager.xlBleOptios.macAddress = macAddress;
                    xlCentralManager.xlBleOptios.writeCharactData = writeCharactData;
                    xlCentralManager.xlBleOptios.dataPages = (writeCharactData.length)/40;
                    [xlCentralManager scanPeripheral];
                } else { // 未指定mac地址，先扫描
                    xlCentralManager.xlBleOptios.macAddress = macAddress;
                    [xlCentralManager scanPeripheral];
                }
            }
        });
        return self;
    };
}

- (XLBluetooth *(^)(void))getHistoryPeripherals { // 获取历史设备
    return ^XLBluetooth * {
        [xlCentralManager getHistoryPeripherals];
        return self;
    };
}

- (XLBluetooth *(^)(CBPeripheral *peripheral, NSString *macAddress, NSString *writeCharactData))connectToPeripheral {
    return ^XLBluetooth *(CBPeripheral *peripheral, NSString *macAddress, NSString *writeCharactData) {
        if (CBCentralManagerStatePoweredOn == (xlCentralManager->centralManager.state)) {
            xlCentralManager.xlBleOptios.macAddress = macAddress;
            xlCentralManager.xlBleOptios.writeCharactData = writeCharactData;
            [xlCentralManager connectToPeripheral:peripheral];
        }
        return self;
    };
}

- (XLBluetooth *(^)(CBPeripheral *peripheral, NSString *macAddress))disconnectToPeripheral {
    return ^XLBluetooth *(CBPeripheral *peripheral, NSString *macAddress) {
        if (CBCentralManagerStatePoweredOn == (xlCentralManager->centralManager.state)) {
            xlCentralManager.xlBleOptios.macAddress = macAddress;
            [xlCentralManager disconnectToPeripheral:peripheral];
        }
        return self;
    };
}

- (XLBluetooth *(^)(void))stopScan { // 停止扫描设备
    return ^XLBluetooth * {
        [xlCentralManager stopScan];
        return self;
    };
}
@end
