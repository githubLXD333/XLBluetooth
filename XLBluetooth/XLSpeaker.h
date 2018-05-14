//
//  XLSpeaker.h
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/12.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLCallBack.h"

@interface XLSpeaker : NSObject
- (XLCallBack *)callback;
- (XLCallBack *)callbackOnCurrChannel;
- (XLCallBack *)callbackOnChnnel:(NSString *)channel;
@end
