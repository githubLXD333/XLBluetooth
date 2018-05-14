//
//  XLBleOptios.h
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/12.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface XLBleOptios : NSObject
@property (nonatomic ,copy) NSString *macAddress;
@property (nonatomic ,copy) NSString *writeCharactData;
@property (nonatomic, assign) NSInteger dataPages;
@property (nonatomic ,copy) NSString *peripheralName;
@property (nonatomic ,copy) CBUUID *writeServerUUID;
@property (nonatomic ,copy) CBUUID *writeCharacteristicUUID;
@property (nonatomic, strong) NSMutableDictionary *retrieveIdentifiers; // 以前连接过的外设macAddress
@end
