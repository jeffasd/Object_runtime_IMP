//
//  ViewController.m
//  test_runtime_02
//
//  Created by jeffasd on 16/7/30.
//  Copyright © 2016年 jeffasd. All rights reserved.
//  非runtime基础教程，如看不明白请先 研究oc的msg_Send方法的消息传递机制 消息是如何通过runtime传递并最终找到函数指针 并通过函数指针调用函数的
//  在此提供一篇文章仅供参考 http://blog.csdn.net/jeffasd/article/details/52073987

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>

static const char * const kReplaceMethod = "Class_replaceMethod";


struct objc_selector_jeffasd
{
    char *types;
    char * sel_name;
};


struct objc_selector_name
{
    const char *    sel_id;
    const char *    sel_types;
};


@interface ViewController ()

@end

@implementation ViewController

+ (void)initialize
{
    
    if (self == [self class]) {
    
        [self replaceMethod];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self useImpInvokeNoUseSEL_Example0];
    
    [self useImpInvokeNotUseSEL_Example1];
    
    [self dynamicAddImplementationByIMPAndInvokeByMsgSendUseOnlyOneSEL];
    
    [self dynamicAddImplementationByIMPAndInvokeByMsgSendUseTwoSEL];
    
    [self SELTypesIsCharPointer];
    
}

- (void)SELTypesIsCharPointer{
    
    Class;
    
    int a = 0;
    
    typeof(a);
    
    NSLog(@"the type is %s", @encode(typeof(a)));
    
    SEL sel = @selector(replaceViewDidLoad);
    
    NSLog(@"the type is %s", @encode(typeof(sel)));
    NSLog(@"the sel is %s", sel);
    
    char * char_sel = "123";
    NSLog(@"char is %s", char_sel);
    
    //    struct objc_selector_name sel_new = *sel;
    
    sizeof(sel);
    
    
    char *p = sel;
    
    NSLog(@"the sizeof is %c", p[0]);
    
    for (int i = 0; ; i++) {
        if (p[i] == nil) {
            
            //            break;
        }else{
            NSLog(@"%c", p[i]);
        }
    }
    
    NSLog(@"the sizeof is %lu", sizeof((*sel)));
    
    
    struct objc_selector_jeffasd sel_jeffasd;
    //    sel_jeffasd->sel_name = "ads";
    
    sel_jeffasd.sel_name = "asd";
    sel_jeffasd.types = "types";
    
    struct objc_selector_jeffasd *pointer = &sel_jeffasd;
    
    
    NSLog(@"the sel_jeffasd type is %s", @encode(typeof(pointer)));
    
    NSLog(@"char sel_jeffasd is %s", sel_jeffasd);
    
}

+ (void)replaceMethod{
    
    
//    IMP replaceIMP = class_getMethodImplementation([self class], @selector(replaceViewDidLoad));
//    //方法替换 - 将viewDidLoad 方法替换为customerViewDidLoad方法
//    class_replaceMethod([self class], @selector(viewDidLoad), replaceIMP, kReplaceMethod);
    
    
    Method originMethod = class_getInstanceMethod([self class], @selector(viewDidLoad));
    Method replaceMethod = class_getInstanceMethod([self class], @selector(exchangeViewDidLoad));
    //两个方法交换
    method_exchangeImplementations(originMethod, replaceMethod);

    
    
}

- (void)replaceViewDidLoad{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
    
    NSLog(@"the replaceViewDidLoad");
}

- (void)exchangeViewDidLoad{
    
    [self exchangeViewDidLoad];
    
    NSLog(@"the exchangeViewDidLoad");
}

#pragma mark - 示例代码
//演示如何不使用SEL在oc中直接调用方法
- (void)useImpInvokeNoUseSEL_Example0{

    IMP imp = [self methodForSelector:@selector(testForImpInvoke0:)];
    //定义一个函数指针
    //typedef struct objc_object *id; oc中id的定义
    int (*pfun)(id, SEL, NSString *);
    //将imp指针强制转换成pfun类型的指针
    //注意IMP指针默认包含 id 此id应该指向函数所在的对象， sel表示此方法名
    //typedef id (*IMP)(id, SEL, ...);
    //obj_msgSend 调用过程 先通过SEL找到SEL对应的IMP函数指针再通过函数指针调用函数
    pfun = (int (*)(id, SEL, NSString *))imp;
    int var = pfun(self, @selector(testForImpInvoke0:), @"hello world");
    NSLog(@"var is %d", var);
    
    var = pfun(@"函数的self并不一定代表self本身!", @selector(testForImpInvoke0:), @"hello world");
    NSLog(@"var1 is %d", var);
    
    var = pfun(@"函数的self并不一定代表self本身!", NSSelectorFromString(@"_cmd不一定代表方法名本身"), @"hello world");
    NSLog(@"var2 is %d", var);
}

//演示不同类型的函数指针如何定义
- (void)useImpInvokeNotUseSEL_Example1{
    //注意直接使用imp(self, ...);必须要设置objc_msgSend Calls 为 NO 这里不使用直接调用的方式调用 使用间接方式调用 既将imp函数指针强转为其本身真正的函数类型
    IMP imp = class_getMethodImplementation([self class], NSSelectorFromString(@"testForImpInvoke1:"));
    //oc中Class的定义 typedef struct objc_class *Class;
    NSString * (*pfun)(id, SEL, NSString *) = (NSString * (*)(id, SEL, NSString *))imp;
    NSString *str = pfun(self, @selector(testForImpInvoke1:), @"example1");
    NSLog(@"str is %@", str);
}

- (void)dynamicAddImplementationByIMPAndInvokeByMsgSendUseOnlyOneSEL{
    
    //通过block方法定义函数指针
    IMP impHaveReturnValue = imp_implementationWithBlock(^(id this, NSString *str){
        
        NSLog(@"this is %@", this);
        NSLog(@"str is %@", str);
        
        NSLog(@"_cmd is %@", NSStringFromSelector(_cmd));
        
        NSLog(@"impHaveReturnValue");
        
        //此处返回值的类型决定了objc_msgSend函数返回值得类型 这一点要注意
        return self;
        
        }
    );
    
    IMP impHaveReturnNothing = imp_implementationWithBlock(^(id this, NSString *str){
        
        NSLog(@"this is %@", this);
        NSLog(@"str is %@", str);
        
        NSLog(@"_cmd is %@", NSStringFromSelector(_cmd));
        
        NSLog(@"impHaveReturnNothing");
        
        //此处返回值的类型决定了objc_msgSend函数返回值得类型 这一点要注意
        
    }
                                                         );
    
//    SEL selName = sel_registerName("selName:");
    SEL selName = NSSelectorFromString(@"selName:");
//    SEL selName = @selector(selName:);
    
    //runtime机制只能动态添加对象方法 类方法既静态方法是在编译阶段就已经确定并放在代码段的
    //同一个SEL添加多个对于的IMP只有第一个添加的IMP有效后面添加的无效
//    class_addMethod([self class], selName, impHaveReturnNothing, "v@:@");
    class_addMethod([self class], selName, impHaveReturnValue, "v@:@");
    class_addMethod([self class], selName, impHaveReturnNothing, "v@:@");
    
    //objc_msgSend()报错Too many arguments to function call ,expected 0,have2
    //Build Setting--> Apple LLVM 6.0 - Preprocessing--> Enable Strict Checking of objc_msgSend Calls  改为 NO
    //这里不使用这个办法使用通过函数指针间接调用的方式来调用msg_Send函数
//    objc_msgSend(self, NSSelectorFromString(@"selName"));
    
//    OBJC_EXPORT id objc_msgSend(id self, SEL op, ...) objc_magSend 函数的定义
    //此处函数指针的返回值类型必须和IMP的函数返回值类型相同否则导致奔溃

//    void (*pMessageSendReturnNothing)(id, SEL, NSString *) = (void (*)(id, SEL, NSString *))&objc_msgSend;
//    pMessageSendReturnNothing(self, selName, @"returnNothing");
    
    id (*pMessageSendHaveReturnValue)(id, SEL, NSString *) = (id (*)(id, SEL, NSString *))&objc_msgSend;
    pMessageSendHaveReturnValue(self, selName, @"return objc value");
    

    void (*pMessageSendReturnNothing)(id, SEL, NSString *) = (void (*)(id, SEL, NSString *))&objc_msgSend;
    pMessageSendReturnNothing(self, selName, @"returnNothing");
    
    
}

- (void)dynamicAddImplementationByIMPAndInvokeByMsgSendUseTwoSEL{
    
    //通过block方法定义函数指针
    IMP impHaveReturnValue = imp_implementationWithBlock(^(id this, NSString *str){
        
        NSLog(@"this is %@", this);
        NSLog(@"str is %@", str);
        
        NSLog(@"_cmd is %@", NSStringFromSelector(_cmd));
        
        NSLog(@"impHaveReturnValue");
        
        //此处返回值的类型决定了objc_msgSend函数返回值得类型 这一点要注意
        return self;
        
    }
                                                         );
    
    IMP impHaveReturnNothing = imp_implementationWithBlock(^(id this, NSString *str){
        
        NSLog(@"this is %@", this);
        NSLog(@"str is %@", str);
        
        NSLog(@"_cmd is %@", NSStringFromSelector(_cmd));
        
        NSLog(@"impHaveReturnNothing");
        
        //此处返回值的类型决定了objc_msgSend函数返回值得类型 这一点要注意
        
    }
                                                           );
    
    SEL selNameReturn = sel_registerName("selNameReturn:");
    SEL selNameNoReturn = NSSelectorFromString(@"selNameNoReturn:");
    //    SEL selName = @selector(selName:);
    
    //runtime机制只能动态添加对象方法 类方法既静态方法是在编译阶段就已经确定并放在代码段的
    //同一个SEL添加多个对于的IMP只有第一个添加的IMP有效后面添加的无效
    //    class_addMethod([self class], selName, impHaveReturnNothing, "v@:@");
    class_addMethod([self class], selNameReturn, impHaveReturnValue, "v@:@");
    class_addMethod([self class], selNameNoReturn, impHaveReturnNothing, "v@:@");
    
    //objc_msgSend()报错Too many arguments to function call ,expected 0,have2
    //Build Setting--> Apple LLVM 6.0 - Preprocessing--> Enable Strict Checking of objc_msgSend Calls  改为 NO
    //这里不使用这个办法使用通过函数指针间接调用的方式来调用msg_Send函数
    //    objc_msgSend(self, NSSelectorFromString(@"selName"));
    
    //    OBJC_EXPORT id objc_msgSend(id self, SEL op, ...) objc_magSend 函数的定义
#warning 此处函数指针的返回值类型必须和IMP的函数返回值类型相同否则导致奔溃
    id (*pMessageSendHaveReturnValue)(id, SEL, NSString *) = (id (*)(id, SEL, NSString *))&objc_msgSend;
    pMessageSendHaveReturnValue(self, selNameReturn, @"return objc value");
    
    
    void (*pMessageSendReturnNothing)(id, SEL, NSString *) = (void (*)(id, SEL, NSString *))&objc_msgSend;
    pMessageSendReturnNothing(self, selNameNoReturn, @"returnNothing");
    
    
    /* 总结
     可以看出SEL自始至终只是一个调用名称，仅此而已，SEL没有其他作用
     SEL和最终的函数调用毫无关系，SEL和IMP以一个key-value方式存放在dispatch_table中，
     SEL为KEY IMP为Value 先从cache中查找，没有找到就从类描述中找
     但一个对象发送消息时，objc_msgSend方法根据对象的isa指针找到对象的类
     然后在类的调度表中找SEL，如果无法找到SEL就通过指向父类的指针找到父类
     并在父类的调度表dispatch_table中查找SEL，以此类推直到NSObject类
     一旦查找到SEL就通过KEY_Value获取SEL对于的IMP通过IMP函数指针调用函数
     */
    
}

#pragma mark - 定义对象方法
- (int)testForImpInvoke0:(NSString *)name{
    
    //函数的self并不一定代表对象本身! 这点要注意 self代表谁和调用者有关
    NSLog(@"self is %@", self);
    //_cmd 也不一定代表方法本身的名字 _cmd代表谁 和调用者有关这点和self一样
    NSLog(@"_cmd is %@", NSStringFromSelector(_cmd));
    NSLog(@"name is %@", name);
    
    NSLog(@"hello world!");
    
    return 123;
}

- (NSString *)testForImpInvoke1:(NSString *)name{
    
    NSLog(@"self is %@", self);
    NSLog(@"_cmd is %@", NSStringFromSelector(_cmd));
    NSLog(@"name is %@", name);
    
    NSLog(@"hello world!");
    
    return name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
