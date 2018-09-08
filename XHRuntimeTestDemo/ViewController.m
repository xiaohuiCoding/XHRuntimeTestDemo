//
//  ViewController.m
//  XHRuntimeTestDemo
//
//  Created by xiaohui on 2018/9/8.
//  Copyright © 2018年 XIAOHUI. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Person+MyCategory.h"
#import "Test.h"
#import <objc/runtime.h>
#import "UIImage+HookImageName.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, assign) NSInteger count;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    Test *t = [[Test alloc] init];
    [t methodCall];
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(120, 480, 60, 30)];
    btn1.backgroundColor = [UIColor redColor];
    [btn1 setTitle:@"放大" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [btn1 addTarget:self action:@selector(button1Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(280, 480, 60, 30)];
    btn2.backgroundColor = [UIColor redColor];
    [btn2 setTitle:@"缩小" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [btn2 addTarget:self action:@selector(button2Clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    /*** 应用一：利用 runtime 给 Category 添加属性，分为两种不同的实现 ***/
    
    Person *p = [[Person alloc] init];
    NSString *varString = [p getMemberVar];
    NSLog(@"成员变量 nameString = %@",varString);
    
    //Category的常规用途：给类添加方法
    [p eatFood];
    [Person eatFood];
    
    //1.给 Category 对应的主类的 实例对象 实现属性调用
    p.name = @"xiaohui";
    NSLog(@"新增的属性：name = %@",p.name);

    //2.给 Category 对应的主类的 类对象 实现属性调用
    Person.associatedObjc = @"HaHaHa";
    NSLog(@"新增类对象的属性：associatedObjc = %@",Person.associatedObjc);
    
    
    
    /*** 应用二：防止多次调用同一方法 ***/
    
    Test *t = [[Test alloc] init];
    [t methodCall];
    [t methodCall];

    
    
    /*** 应用三：HOOK 可以全局替换需要使用的资源名称（UI同学最近重新切了一套图，图片资源统一添加前缀"new_"） ***/
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, 100, 100)];
    _imgView.image = [UIImage imageNamed:@"avatar"];
    [self.view addSubview:_imgView];
    
    
    
    /*** 应用四：动态创建类，修改已有类 ***/
    
    //1.动态的创建一个类，添加成员变量，添加方法，添加属性，以及使用创建出来的类
    Class newClass = objc_allocateClassPair([Person class], "NewPerson", 0);
    class_addMethod(newClass, @selector(instanceMethod), (IMP)dynamicAddInstanceMethodImplementation, "v@:");
    //给新类添加成员变量
    class_addIvar(newClass, "_newName", sizeof(NSString *), log(sizeof(NSString *)), "i");
    //给新类添加属性
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t c = { "C", "" };
    objc_property_attribute_t v = { "V", "_newName"};
    objc_property_attribute_t attrs[] = {type, c, v};
    class_addProperty(newClass, "newProperty", attrs, 3);
    //注册新类，注册后才可以使用新类
    objc_registerClassPair(newClass);
    //给新类添加类方法，其实是要给元类的方法列表新增方法
    Class metaClass = objc_getMetaClass("NewPerson");
    class_addMethod(metaClass, @selector(classMethod), (IMP)dynamicAddClassMethodImplementation, "v@:");
    //使用新类
    id instance = [[newClass alloc] init];
    [instance performSelector:@selector(instanceMethod)];
    [newClass performSelector:@selector(classMethod)];
    //输出新类的运行时属性
    [self logProperty:[newClass class]];
    
    //2.动态给已有类添加属性
    objc_property_attribute_t t2 = {"T", "@\"NSString\""};
    objc_property_attribute_t c2 = { "C", "" };
    objc_property_attribute_t v2 = { "V", "_newName"};
    objc_property_attribute_t attrs2[] = {t2, c2, v2};
    class_addProperty([Person class], "newName", attrs2, 3);
    //输出已有类的运行时属性
    [self logProperty:[Person class]];
}

void dynamicAddInstanceMethodImplementation(id self, SEL _cmd) {
    NSLog(@"new class's instance method execute");
}

void dynamicAddClassMethodImplementation(id self, SEL _cmd) {
    NSLog(@"new class's class method execute");
}

- (void)logProperty:(Class)class {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    NSLog(@"属性的个数是：%d",count);
    for (NSInteger i=0; i<count; i++) {
        NSString *name = @(property_getName(properties[i]));
        NSString *attributes = @(property_getAttributes(properties[i]));
        NSLog(@"属性：%@ --- %@",name, attributes);
    }
}



- (void)button1Clicked:(UIButton *)sender {
    [_imgView setFrame:CGRectMake(0, 64, _imgView.frame.size.width+10, _imgView.frame.size.height+10)];
}

- (void)button2Clicked:(UIButton *)sender {
    [_imgView setFrame:CGRectMake(0, 64, _imgView.frame.size.width-10, _imgView.frame.size.height-10)];
}

@end
