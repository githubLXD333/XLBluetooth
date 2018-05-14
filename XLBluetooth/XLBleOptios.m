//
//  XLBleOptios.m
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/12.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import "XLBleOptios.h"
#import "XLDefine.h"

static NSString * const kPeripheralName = @"veltinis01";
// 写服务
static NSString * const kWriteServerUUID = @"FFF0";
// 写特征值
static NSString * const kWriteCharacteristicUUID = @"FFF1";

@implementation XLBleOptios
- (instancetype)init {
    if (self = [super init]) {
        _macAddress = @"";
        _peripheralName = kPeripheralName;
        _writeServerUUID = [CBUUID UUIDWithString:kWriteServerUUID];
        _writeCharacteristicUUID = [CBUUID UUIDWithString:kWriteCharacteristicUUID];
        
        _retrieveIdentifiers = [[XLBleUserDefaults objectForKey:kRetrieveIdentifier] mutableCopy];
        if (!_retrieveIdentifiers) {
            _retrieveIdentifiers = [NSMutableDictionary dictionary];
        }
    }
    return self;
}
@end
