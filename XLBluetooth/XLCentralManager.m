//
//  XLCentralManager.m
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/12.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import "XLCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "XLDefine.h"
#import "HFUtilityClass.h"

#define currChannel [xlSpeaker callbackOnCurrChannel]

@interface XLCentralManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBPeripheral *cbPeripheral; // 保存已连接的荧光棒
    CBPeripheral *ptPeripheral; // 保存蓝牙打印设备
}
@property (nonatomic, assign) int currentIndex; // 写入特征字符串的下标
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation XLCentralManager
- (instancetype)init {
    if (self = [super init]) {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)getHistoryPeripherals {
    NSArray *historyPeripherals;
    NSMutableArray *historyUUIDArr = [NSMutableArray array];
    for (NSString *uuidString in self.xlBleOptios.retrieveIdentifiers.allValues) {
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
        [historyUUIDArr addObject:uuid];
    }
    historyPeripherals = [centralManager retrievePeripheralsWithIdentifiers:historyUUIDArr];
    
    if ([currChannel blockOnHistoryPeripherals]) {
        currChannel.blockOnHistoryPeripherals(centralManager, historyPeripherals, self.xlBleOptios.retrieveIdentifiers);
    }
}

- (void)scanPeripheral { // 扫描Peripheral
    CBUUID *servicesUUID = self.xlBleOptios.writeServerUUID;
    [centralManager scanForPeripheralsWithServices:@[servicesUUID] options:nil];
}
- (void)stopScan {
    [centralManager stopScan];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.timer invalidate];
        self.timer = nil;
    });
}
- (void)connectToPeripheral:(CBPeripheral *)peripheral { // 连接Peripherals
    [centralManager connectPeripheral:peripheral options:nil];
}
- (void)disconnectToPeripheral:(CBPeripheral *)peripheral { // 断开Peripherals
    [self p_removeIdentifier:peripheral];
}

#pragma mark --- CBCentralManager delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            XLLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            XLLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            XLLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            XLLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            XLLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            XLLog(@">>>CBCentralManagerStatePoweredOn");
            break;
        default:
            break;
    }
    //状态改变callback
    if ([currChannel blockOnCentralManagerDidUpdateState]) {
        [currChannel blockOnCentralManagerDidUpdateState](central);
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSString *macAddress = [NSString stringWithFormat:@"%@", advertisementData[@"kCBAdvDataManufacturerData"]];
    macAddress = [HFUtilityClass getMacWithString:macAddress];
//    macAddress = [macAddress stringByReplacingOccurrencesOfString:@":" withString:@""];
    if ([macAddress containsString:self.xlBleOptios.macAddress]) { // 扫描到目标设备
        XLLog(@"扫描到的外设设备信息为:%@", peripheral);
        XLLog(@"advertisementData is:%@", advertisementData);
        XLLog(@"kCBAdvDataManufacturerData class is:%@", NSStringFromClass([advertisementData[@"kCBAdvDataManufacturerData"] class]));
        cbPeripheral = peripheral;
        [centralManager stopScan];
        
        // 扫描到设备后自动连接
        [self connectToPeripheral:cbPeripheral];
        
        // 扫描到设备callback
        if ([currChannel filterOnDiscoverPeripherals]) {
            if ([currChannel filterOnDiscoverPeripherals](peripheral.name,advertisementData,RSSI)) {
                if ([currChannel blockOnDiscoverPeripherals]) {
                    [[xlSpeaker callbackOnCurrChannel] blockOnDiscoverPeripherals](central, peripheral, advertisementData, RSSI);
                }
            }
        }
        
        if (self.timer) {
            [self.timer invalidate];
        }
    } else if ([self.xlBleOptios.macAddress isEqualToString:@"printer"]) { // 只连接设备，不写入数据
        ptPeripheral = peripheral;
        [centralManager stopScan];
        
        // 扫描到设备后自动连接
        [self connectToPeripheral:ptPeripheral];
    } else { // 只进行设备扫描，返回扫描到的设备信息
        XLLog(@"------------------- 未找到指定的蓝牙设备 -------------------");
        if ([currChannel filterOnDiscoverPeripherals]) {
            if ([currChannel blockOnDiscoverPeripherals]) {
                [[xlSpeaker callbackOnCurrChannel] blockOnDiscoverPeripherals](central, peripheral, advertisementData, RSSI);
                if (!self.timer) { // 开启定时器
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(p_readRSSI) userInfo:nil repeats:1.0];
                    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
                }
            }
        }
    }
}

- (void)p_readRSSI {
    [self scanPeripheral];
}

/**
 连接成功
 
 @param central 中心管理者
 @param peripheral 连接成功的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if ([self.xlBleOptios.macAddress isEqualToString:@"printer"]) {
        if ([currChannel filterOnDiscoverPeripherals]) {
            if ([currChannel blockOnConnectedPeripheral]) {
                [[xlSpeaker callbackOnCurrChannel] blockOnConnectedPeripheral](central, ptPeripheral, self.xlBleOptios.macAddress);
            }
        }
        return;
    }
    
    cbPeripheral = peripheral;
    cbPeripheral.delegate = self;
    CBUUID *servicesUUID = self.xlBleOptios.writeServerUUID;
    [cbPeripheral discoverServices:@[servicesUUID]];
}

/**
 连接失败
 
 @param central 中心管理者
 @param peripheral 连接失败的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    XLLog(@"连接失败");
    if ([currChannel blockOnFailToConnect]) {
        [currChannel blockOnFailToConnect](central, peripheral, error);
    }
}

/**
 连接断开
 @param central 中心管理者
 @param peripheral 连接断开的设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    XLLog(@"断开连接");
    if (self.currentIndex > 0 && (self.currentIndex != self.xlBleOptios.dataPages)) { // 数据写入中断
        if ([currChannel blockOnWritingDataBreak]) {
            [currChannel blockOnWritingDataBreak](centralManager, cbPeripheral, self.xlBleOptios.macAddress);
        }
    }
}

/**
 扫描到服务
 
 @param peripheral 服务对应的设备
 @param error 扫描错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) { // 遍历所有的服务
        if ([service.UUID isEqual:self.xlBleOptios.writeServerUUID]) {
            XLLog(@"扫描到对应的服务:%@", service.UUID.UUIDString);
            // 根据你要的那个服务去发现特性
            CBUUID *characteristicUUID = self.xlBleOptios.writeCharacteristicUUID;
            [cbPeripheral discoverCharacteristics:@[characteristicUUID] forService:service];
        }
    }
}

/**
 扫描到对应的特征
 
 @param peripheral 设备
 @param service 特征对应的服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) { // 遍历所有的特征
        // 获取对应的特征
        if ([characteristic.UUID isEqual:self.xlBleOptios.writeCharacteristicUUID]) {
            XLLog(@"扫描到对应的特征:%@", characteristic.UUID.UUIDString);
            
            if ([currChannel blockOnWritingData]) { // 开始往荧光棒写入数据
                [currChannel blockOnWritingData](centralManager, cbPeripheral, self.xlBleOptios.macAddress);
            }
            
//            NSString *lastHexString = [self p_getLastHexString]; // test data
            self.currentIndex = 0; // 初始化写入数据的下标
            NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", self.currentIndex, 40];
            NSString *sendStr = [self.xlBleOptios.writeCharactData substringWithRange:NSRangeFromString(rangeStr)];
            [self p_writeDataToPeripheral:characteristic hexString:sendStr];
            
//            for (int i = 0; i < lastHexString.length; i += 40) {
//                NSString *rangeStr = [NSString stringWithFormat:@"%i,%i", i, 40];
//                NSString *sendStr = [lastHexString substringWithRange:NSRangeFromString(rangeStr)];
//                [self p_writeDataToPeripheral:characteristic hexString:sendStr];
//            }
            break;
        }
    }
}

/**
 根据特征读到数据
 
 @param peripheral 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSData *data = characteristic.value;
    XLLog(@"characteristic changed value is:%@",data);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    XLLog(@"characteristic did updata success:%@", characteristic);
    
    self.currentIndex ++;
    XLLog(@"dataPages is:%ld --------- self.currentIndex:%d", self.xlBleOptios.dataPages, self.currentIndex);
    if (0 == self.currentIndex%13) { // 每写完一页，停留5秒
        XLLog(@"当前数据写到第 %d 页", self.currentIndex/13);
        [NSThread sleepForTimeInterval:2.5];
    }
    if (self.currentIndex < self.xlBleOptios.dataPages) {
        NSString *rangeStr = [NSString stringWithFormat:@"%i, %i", self.currentIndex*40, 40];
        NSString *sendStr = [self.xlBleOptios.writeCharactData substringWithRange:NSRangeFromString(rangeStr)];
        [self p_writeDataToPeripheral:characteristic hexString:sendStr];
    } else if (self.currentIndex == self.xlBleOptios.dataPages) {
        // 数据写入成功,保存该设备的identifier
        NSString *peripheralID = [NSString stringWithFormat:@"%@", peripheral.identifier];
        [self p_saveIdentifier:peripheralID];
    }
}

- (void)p_writeDataToPeripheral:(CBCharacteristic *)characteristic hexString:(NSString *)hexString {
    XLLog(@"send the hexString is:%@", hexString);
    [cbPeripheral setNotifyValue:YES forCharacteristic:characteristic];
    [cbPeripheral writeValue:[self p_hexToBytes:hexString] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (NSData *)p_hexToBytes:(NSString *)str {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

- (void)p_saveIdentifier:(NSString *)peripheralID {
    if (self.xlBleOptios.macAddress.length && peripheralID.length) {
        self.xlBleOptios.retrieveIdentifiers[self.xlBleOptios.macAddress] = peripheralID;
        [XLBleUserDefaults setObject:self.xlBleOptios.retrieveIdentifiers forKey:kRetrieveIdentifier];
        [XLBleUserDefaults synchronize];
        
        if ([currChannel blockOnWritedPeripheral]) { // 扫描到设备，并且数据写入成功callback
            [currChannel blockOnWritedPeripheral](centralManager, cbPeripheral, self.xlBleOptios.macAddress);
        }
        
        XLLog(@"self.xlBleOptios.retrieveIdentifiers:%@", self.xlBleOptios.retrieveIdentifiers);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [centralManager cancelPeripheralConnection:cbPeripheral];
            cbPeripheral = nil;
        });
    }
}

- (void)p_removeIdentifier:(CBPeripheral *)peripheral {
    if (self.xlBleOptios.macAddress.length) {
        if ([currChannel blockOnDisConnectedPeripheral]) { // 断开设备成功callback
            [currChannel blockOnDisConnectedPeripheral](centralManager, peripheral, self.xlBleOptios.macAddress);
        }
    }
}

#pragma mark --- 测试阶段使用的代码
- (NSString *)p_getLastHexString {
    NSString *groupString = @"";
    for (int i = 0; i < 80; i ++) {
        // 拼接图形
        NSString *singleChart = [self p_getHexByDecimal:i+1];
        if (1 == singleChart.length) {
            singleChart = [NSString stringWithFormat:@"0%@", singleChart];
        }
        groupString = [groupString stringByAppendingString:singleChart];
        
        // 拼接颜色
        NSString *singleColor = [self p_getHexByDecimal:i%8];
        XLLog(@"singleColor is:%@", singleColor);
        if (singleColor.intValue >= 1) {
            singleColor = [NSString stringWithFormat:@"%d", singleColor.intValue - 1];
        } else {
            singleColor = [NSString stringWithFormat:@"%d", 7];
        }
        XLLog(@"last singleColor is:%@", singleColor);
        singleColor = [NSString stringWithFormat:@"0%@", singleColor];
        groupString = [groupString stringByAppendingString:singleColor];
        
        // 拼接时间
        if (0 == i) {
            groupString = [groupString stringByAppendingString:@"1a"];
        } else if (1 == i) {
            groupString = [groupString stringByAppendingString:@"3a"];
        } else if (2 == i) {
            groupString = [groupString stringByAppendingString:@"5a"];
        } else if (3 == i) {
            groupString = [groupString stringByAppendingString:@"7a"];
        } else if (4 == i) {
            groupString = [groupString stringByAppendingString:@"aa"];
        } else {
            groupString = [groupString stringByAppendingString:@"28"];
        }
    }
    // 补19个字节
    NSString *fillString = @"0000000000000000000fffffffffffffffffff";
    NSString *totalHexString = [NSString stringWithFormat:@"01%@%@", groupString, fillString];
    XLLog(@"totalHexString is:%@ ---------- totalHexString.length:%ld", totalHexString, totalHexString.length);
    
    return totalHexString;
}
- (NSString *)p_getHexByDecimal:(NSInteger)decimal { // 十进制转换为十六进制
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
                
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}
- (void)p_writeDataToPeripheral111:(CBCharacteristic *)characteristic {
    // 订阅特性，当数据频繁改变时，一般用它， 不用readValueForCharacteristic
    [cbPeripheral setNotifyValue:YES forCharacteristic:characteristic];
    
    unsigned char send[20];
    send[0] = 0xFB;
    send[1] = 0xA1;
    send[2] = 0x03;
    send[3] = 0xA0;
    send[4] = 0x32;
    send[5] = 0x00;
    send[6] = 0xB0;
    send[7] = 0xA1;
    send[8] = 0xFB;
    send[9] = 0xA1;
    send[10] = 0x03;
    send[11] = 0xA0;
    send[12] = 0xA1;
    send[13] = 0x32;
    send[14] = 0x00;
    send[15] = 0xB0;
    send[16] = 0xA1;
    send[17] = 0xFB;
    send[18] = 0xA1;
    send[19] = 0xA0;
    NSData *data = [NSData dataWithBytes:send length:20];
    
    [cbPeripheral writeValue:[self p_hexToBytes:@"FB02FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void)p_testMethod {
    ///// 将16进制数据转化成Byte 数组
    NSString *hexString = @"3e435fab9c34891f"; //16进制字符串
    int j = 0;
    Byte bytes[128];  ///3ds key的Byte 数组， 128位
    
    for(int i = 0; i < [hexString length]; i++) {
        int int_ch;  /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if (hex_char1 >= '0' && hex_char1 <='9') {
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        } else if (hex_char1 >= 'A' && hex_char1 <='F') {
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        } else {
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        }
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9') {
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        } else if (hex_char1 >= 'A' && hex_char1 <='F') {
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        } else {
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        }
        int_ch = int_ch1+int_ch2;
        NSLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    
    NSLog(@"the bytes result is:%@", bytes);
}
@end
