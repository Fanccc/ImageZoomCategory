//
//  SubScrollView.m
//  ImageCategry
//
//  Created by fanchuan on 2017/6/23.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "SubScrollView.h"

@implementation SubScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    NSLog(@"dqwdqwdwqdqw");
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch{
    NSLog(@"12312312");
    return YES;
}

@end
