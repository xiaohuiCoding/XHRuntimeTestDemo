//
//  UIImage+HookImageName.m
//  OCTest
//
//  Created by xiaohui on 2018/9/6.
//  Copyright © 2018年 XIAOHUI. All rights reserved.
//

#import "UIImage+HookImageName.h"
#import <objc/runtime.h>

@implementation UIImage (HookImageName)

+ (void)load {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        Class selfClass = object_getClass([self class]);
        
        SEL originSEL = @selector(imageNamed:);
        Method originMethod = class_getInstanceMethod(selfClass, originSEL);
        
        SEL customSEL = @selector(myImageNamed:);
        Method customMethod = class_getInstanceMethod(selfClass, customSEL);
        
        BOOL b = class_addMethod(selfClass, originSEL, method_getImplementation(customMethod), method_getTypeEncoding(customMethod));
        
        if (b) {
            class_replaceMethod(selfClass, customSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        } else {
            method_exchangeImplementations(originMethod, customMethod);
        }
        
    });
}

+ (UIImage *)myImageNamed:(NSString *)name {
    
    NSString *newName = [NSString stringWithFormat:@"%@%@", @"new_", name];
    return [self myImageNamed:newName];
}

@end
