//
//  XLDefine.h
//  BLE4.0_Test_Demo
//
//  Created by yuan on 2017/12/12.
//  Copyright © 2017年 lxd. All rights reserved.
//

#ifndef XLDefine_h
#define XLDefine_h

// if show log 是否打印日志，默认1：打印 ，0：不打印
#define KXL_IS_SHOW_LOG 1

// XL默认链式方法channel名称
#define KXL_DETAULT_CHANNEL @"xlDefault"

#ifdef DEBUG
#define XLLog(s,...) NSLog(@"[在%@中第%d行] %@", [[NSString stringWithFormat:@"%s", __FILE__] lastPathComponent] ,__LINE__, [NSString stringWithFormat:(s),##__VA_ARGS__])
#else
#define XLLog(...)

#endif

#define XLBleUserDefaults [NSUserDefaults standardUserDefaults]
static NSString * const kRetrieveIdentifier = @"kRetrieveIdentifier";
#endif /* XLDefine_h */
