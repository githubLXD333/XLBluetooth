//
//  HFUtilityClass.m
//  Fan+
//
//  Created by yuan on 2017/12/22.
//  Copyright © 2017年 lxd. All rights reserved.
//

#import "HFUtilityClass.h"

@implementation HFUtilityClass
+ (BOOL)containsViewController:(NSString *)className viewControllers:(NSArray *)viewControllers {
    for (UIViewController *viewController in viewControllers) {
        NSString *subClassName = NSStringFromClass([viewController class]);
        if ([subClassName isEqualToString:className]) {
            return YES;
        }
    }
    return NO;
}

+ (UIViewController *)getCurrentVC {
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    if (!window) {
        return nil;
    }
    UIView *tempView;
    for (UIView *subview in window.subviews) {
        if ([[subview.classForCoder description] isEqualToString:@"UILayoutContainerView"]) {
            tempView = subview;
            break;
        }
    }
    if (!tempView) {
        tempView = [window.subviews lastObject];
    }
    
    id nextResponder = [tempView nextResponder];
    while (![nextResponder isKindOfClass:[UIViewController class]] || [nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UITabBarController class]]) {
        tempView =  [tempView.subviews firstObject];
        
        if (!tempView) {
            return nil;
        }
        nextResponder = [tempView nextResponder];
    }
    return  (UIViewController *)nextResponder;
}

+ (NSString *)getMacWithString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSMutableArray *tempStrArr = [NSMutableArray array];
    for (int i = 0; i < string.length; i ++) {
        if (0 == i) {
            [tempStrArr addObject:[string substringWithRange:NSMakeRange(0, 2)]];
        } else if (0 == i % 2) {
            [tempStrArr addObject:[string substringWithRange:NSMakeRange(i, 2)]];
        }
    }
    NSArray *reversedArray = [[tempStrArr reverseObjectEnumerator] allObjects];
    NSString *macStr = [reversedArray componentsJoinedByString:@":"];
    
    return [macStr uppercaseString];
}

+ (NSString *)getMacWithColon:(NSString *)QRCode {
    NSMutableArray *tempStrArr = [NSMutableArray array];
    for (int i = 0; i < QRCode.length; i ++) {
        if (0 == i) {
            [tempStrArr addObject:[QRCode substringWithRange:NSMakeRange(0, 2)]];
        } else if (0 == i % 2) {
            [tempStrArr addObject:[QRCode substringWithRange:NSMakeRange(i, 2)]];
        }
    }
    NSString *macStr = [tempStrArr componentsJoinedByString:@":"];
    
    return [macStr uppercaseString];
}
@end
