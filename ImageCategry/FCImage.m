//
//  FCImage.m
//  ImageCategry
//
//  Created by fanchuan on 2017/6/21.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "FCImage.h"

@interface FCImage ()

@property (nonatomic, strong) UIView *redView;

@end

@implementation FCImage

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _redView.backgroundColor = [UIColor redColor];
        _redView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:_redView];
    }
    return self;
}

- (void)layoutSubviews{
    _redView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

@end
