//
//  CustomScrollView.m
//  ImageCategry
//
//  Created by fanchuan on 2017/6/23.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "CustomScrollView.h"
#import <objc/runtime.h>

@implementation CustomScrollView

+ (void)load{
    //如果scrollview没有实现这个method 会拿到父类的该方法
    Method originMethod = class_getInstanceMethod(self, NSSelectorFromString(@"handlePan:"));
    Method newMethod = class_getInstanceMethod(self, @selector(fc_handlePan:));
    
    //向自身添加新方法的实现,若果成功了说明自身并没有实现该方法
    BOOL addSuccess = class_addMethod(self, NSSelectorFromString(@"handlePan:"), method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if(addSuccess){
        //将父类的实现替换到新方法下.
        //这时候调用handlepan调用的就是fc_handlePan的实现.本来是空,内部[self fc_handlePan].因为fc_handlePan调用的是原来的实现,这样就实现了swizzling
        class_replaceMethod(self, @selector(fc_handlePan:), method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    }else{
        //同理
        method_exchangeImplementations(originMethod, newMethod);
    }
}

- (void)fc_handlePan:(UIGestureRecognizer *)pan{
    [self fc_handlePan:pan];
    if(self.subViewBeginDismiss){
        self.subViewBeginDismiss((UIPanGestureRecognizer *)pan);
    }
}

@end
