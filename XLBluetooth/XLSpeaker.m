//
//  XLSpeaker.m
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/12.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import "XLSpeaker.h"
#import "XLDefine.h"

@implementation XLSpeaker
{
    //所有委托频道
    NSMutableDictionary *channels;
    //当前委托频道
    NSString *currChannel;
}

- (instancetype)init {
    if (self = [super init]) {
        XLCallBack *defaultCallback = [[XLCallBack alloc] init];
        channels = [NSMutableDictionary dictionary];
        currChannel = KXL_DETAULT_CHANNEL;
        channels[KXL_DETAULT_CHANNEL] = defaultCallback;
    }
    return self;
}

- (XLCallBack *)callback {
    return channels[KXL_DETAULT_CHANNEL];
}

- (XLCallBack *)callbackOnCurrChannel {
    return [self callbackOnChnnel:currChannel];
}

- (XLCallBack *)callbackOnChnnel:(NSString *)channel {
    if (!channel) {
        [self callback];
    }
    return channels[channel];
}
@end
