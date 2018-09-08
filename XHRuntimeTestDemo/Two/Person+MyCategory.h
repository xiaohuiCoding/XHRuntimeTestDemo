//
//  Person+MyCategory.h
//  MessageForwardingTestDemo
//
//  Created by xiaohui on 2018/9/4.
//  Copyright © 2018年 XIAOHUI. All rights reserved.
//

#import "Person.h"

@interface Person (MyCategory)
//{
//    //不可以这样给类直接添加成员变量，因为在运行期，对象的内存布局已经确定，如果添加成员变量会破坏类的内部布局。
//    NSString *name;
//}

//可以这样直接给类添加属性，但无法使用，因为分类并没有默认实现setter和getter方法；可以利用的runtime关联对象方式来模拟实现setter和getter方法，然后就可使用添加的属性了。
@property (nonatomic, copy) NSString *name;

//可以给类添加方法，默认支持这么做。
- (void)eatFood;
+ (void)eatFood;

//给类对象添加属性
+ (void)setAssociatedObjc:(NSString *)associatedObjc;
+ (NSString *)associatedObjc;

@end
