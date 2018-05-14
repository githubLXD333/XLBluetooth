//
//  XLBluetooth.h
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/11.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface XLBluetooth : NSObject
+ (instancetype)shareXLBluetooth;
+ (void)attempDealloc;

- (void)setBlockOnCentralManagerDidUpdateState:(void (^)(CBCentralManager *central))block;
/**
 找到Peripherals的block |  when find peripheral
 */
- (void)setBlockOnDiscoverToPeripherals:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI))block;

/**
 连接Peripherals成功的block
 |  when connected peripheral
 */
- (void)setBlockOnConnected:(void (^)(CBCentralManager *central,CBPeripheral *peripheral, NSString *macAddress))block;

/**
 连接Peripherals失败的block
 |  when fail to connect peripheral
 */
- (void)setBlockOnFailToConnect:(void (^)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error))block;

/**
 开始写入数据的block
 |  when connected peripheral
 */
- (void)setBlockOnWritingData:(void (^)(CBCentralManager *central,CBPeripheral *peripheral, NSString *macAddress))block;

/**
 写入数据，中途断开的block
 |  when connected peripheral
 */
- (void)setBlockOnWritingDataBreak:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress))block;
//写入数据到Peripherals成功的委托
- (void)setBlockOnWrited:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress))block;
- (void)setBlockOnHistoryPeripherals:(void (^)(CBCentralManager *central, NSArray<CBPeripheral *> *peripherals, NSDictionary *macAddressDict))block;
/**
 断开Peripherals成功的block
 |  when disconnected peripheral
 */
- (void)setBlockOnDisConnected:(void (^)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress))block;

- (XLBluetooth *(^)(NSString *macAddress, NSString *writeCharactData))scanForPeripheral;
- (XLBluetooth *(^)(void))getHistoryPeripherals;
- (XLBluetooth *(^)(CBPeripheral *peripheral, NSString *macAddress, NSString *writeCharactData))connectToPeripheral;
- (XLBluetooth *(^)(CBPeripheral *peripheral, NSString *macAddress))disconnectToPeripheral;
- (XLBluetooth *(^)(void))stopScan;
@end
