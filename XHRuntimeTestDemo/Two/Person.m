//
//  Person.m
//  MessageForwardingTestDemo
//
//  Created by xiaohui on 2018/9/3.
//  Copyright © 2018年 XIAOHUI. All rights reserved.
//

#import "Person.h"

@implementation Person

- (NSString *)getMemberVar {
    //给成员变量赋值
    self->nameString = @"xiaohui";
    return self->nameString;
}

@end
