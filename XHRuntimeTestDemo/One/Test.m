//
//  Test.m
//  XHRuntimeTestDemo
//
//  Created by xiaohui on 2018/9/8.
//  Copyright © 2018年 XIAOHUI. All rights reserved.
//

#import "Test.h"
#import <objc/runtime.h>

@implementation Test

- (void)methodCall {
    // 利用runtime给对象增加一个属性，检测在对象生命周期内该属性是否存在，从而防止多次调用同一方法
    if (objc_getAssociatedObject(self, _cmd)) {
        return;
    } else {
        objc_setAssociatedObject(self, _cmd, @"methodCallProperty", OBJC_ASSOCIATION_RETAIN);
    }
    
    NSLog(@"this method only execute once");
}

@end
