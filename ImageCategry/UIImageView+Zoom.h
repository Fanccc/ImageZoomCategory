//
//  UIImageView+Scale.h
//  ImageCategry
//
//  Created by fanchuan on 2017/6/20.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import <UIKit/UIKit.h>

//长按
typedef void(^longPressedAction)();

@interface UIImageView (Zoom)
//是否允许缩放
@property (nonatomic) BOOL allowScale;
//背景色 默认黑色
@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, copy) longPressedAction longPressedBlock;

@end
