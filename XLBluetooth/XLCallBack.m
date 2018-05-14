//
//  XLCallBack.m
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/12.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import "XLCallBack.h"

@implementation XLCallBack
- (instancetype)init {
    self = [super init];
    if (self) {
        self.filterOnDiscoverPeripherals = ^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
            if (![peripheralName isEqualToString:@""]) {
                return YES;
            }
            return NO;
        };
        
        self.filterOnconnectToPeripherals = ^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
            if (![peripheralName isEqualToString:@""]) {
                return YES;
            }
            return NO;
        };
    }
    return self;
}
@end
