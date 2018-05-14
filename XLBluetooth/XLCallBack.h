//
//  XLCallBack.h
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/12.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

// 设备状态改变的委托
typedef void (^XLCentralManagerDidUpdateStateBlock)(CBCentralManager *central);
// 找到设备的委托
typedef void (^XLDiscoverPeripheralsBlock)(CBCentralManager *central,CBPeripheral *peripheral,NSDictionary *advertisementData, NSNumber *RSSI);
// 连接设备成功的block
typedef void (^XLConnectedPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress);
// 写入数据成功的block
typedef void (^XLWritedPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress);
// 正在写入数据的block
typedef void (^XLWritingDataBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress);
// 正在写入数据， 中途断开的block
typedef void (^XLWritingDataBreakBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress);
// 断开设备成功的block
typedef void (^XLDisConnectedPeripheralBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSString *macAddress);
//连接设备失败的block
typedef void (^XLFailToConnectBlock)(CBCentralManager *central,CBPeripheral *peripheral,NSError *error);
// 获取历史设备的block
typedef void (^XLHistoryPeripheralsBlock)(CBCentralManager *central, NSArray<CBPeripheral *> *peripherals, NSDictionary *macAddressDict);

@interface XLCallBack : NSObject
#pragma mark - callback block
// 设备状态改变的委托
@property (nonatomic, copy) XLCentralManagerDidUpdateStateBlock blockOnCentralManagerDidUpdateState;
// 发现peripherals
@property (nonatomic, copy) XLDiscoverPeripheralsBlock blockOnDiscoverPeripherals;
// 连接成功callback
@property (nonatomic, copy) XLConnectedPeripheralBlock blockOnConnectedPeripheral;
// 希望如数据成功callback
@property (nonatomic, copy) XLWritedPeripheralBlock blockOnWritedPeripheral;
// 正在写入数据的callback
@property (nonatomic, copy) XLWritingDataBlock blockOnWritingData;
// 正在写入数据，中途断开的callback
@property (nonatomic, copy) XLWritingDataBreakBlock blockOnWritingDataBreak;
// 断开成功callback
@property (nonatomic, copy) XLDisConnectedPeripheralBlock blockOnDisConnectedPeripheral;
//连接设备失败的block
@property (nonatomic, copy) XLFailToConnectBlock blockOnFailToConnect;
// 获取连接过的历史设备callback
@property (nonatomic, copy) XLHistoryPeripheralsBlock blockOnHistoryPeripherals;

#pragma mark - 过滤器Filter
//发现peripherals规则
@property (nonatomic, copy) BOOL (^filterOnDiscoverPeripherals)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);
//连接peripherals规则
@property (nonatomic, copy) BOOL (^filterOnconnectToPeripherals)(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI);
@end
