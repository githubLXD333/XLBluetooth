//
//  HFUtilityClass.h
//  Fan+
//
//  Created by yuan on 2017/12/22.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HFUtilityClass : NSObject
+ (UIViewController *)getCurrentVC;
+ (BOOL)containsViewController:(NSString *)className viewControllers:(NSArray *)viewControllers;

/**
  mac地址转换
 */
+ (NSString *)getMacWithString:(NSString *)string;

/**
 将二维码中的mac地址添加“:”号
 */
+ (NSString *)getMacWithColon:(NSString *)QRCode;
@end
