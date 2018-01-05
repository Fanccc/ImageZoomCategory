//
//  UIImageView+Scale.m
//  ImageCategry
//
//  Created by fanchuan on 2017/6/20.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "UIImageView+Browse.h"
#import "AppDelegate.h"
#import "UIView+Sizes.h"
#import <objc/runtime.h>

#define stringFromPoint(x) NSStringFromCGPoint(x)
/** 设备屏幕宽 */
#define kMainScreenWidth  [UIScreen mainScreen].bounds.size.width
/** 设备屏幕高度 */
#define kMainScreenHeight [UIScreen mainScreen].bounds.size.height

//private class
@interface FCImageViewScaleExtension : NSObject<UIScrollViewDelegate,UIGestureRecognizerDelegate>
//容器视图
@property (nonatomic, strong) UIView *containerView;
//放大相关
@property (nonatomic, assign) BOOL browseEnabled;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIImageView *sourceImageView;
@property (nonatomic, strong) UIView *sourceImageViewSuperView;
@property (nonatomic, assign) CGRect startRect;
@property (nonatomic, assign) CGRect startAnimationRect;
@property (nonatomic, strong) UIScrollView *scrollView;
//手势
@property (nonatomic, strong) UITapGestureRecognizer *tapAction;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapAction;
@property (nonatomic, copy) longPressedAction longPressedBlock;

@end

@implementation FCImageViewScaleExtension

- (instancetype)init{
    if(self = [super init]){
        _backgroundColor = [UIColor blackColor];
        _isShow = NO;
    }
    return self;
}

- (void)show{
    if(!_scrollView){
        [self configScrollView];
    }
    
    _isShow = YES;
    
    _startRect = _sourceImageView.frame;
    _startAnimationRect = [self imageViewFrameOnKeyWindow];
    _sourceImageViewSuperView = _sourceImageView.superview;
    
    [_sourceImageView removeFromSuperview];
    _sourceImageView.frame = _startAnimationRect;
    [self.containerView addSubview:_scrollView];
    _scrollView.backgroundColor = [_backgroundColor colorWithAlphaComponent:0];
    
    CGSize imageSize = CGSizeMake(self.containerView.width, self.containerView.width/(_sourceImageView.image.size.width/_sourceImageView.image.size.height));
    CGSize contentSize = CGSizeMake(self.containerView.width, MAX(imageSize.height, self.containerView.height));
    
    self.scrollView.contentSize = contentSize;
    self.imageContainerView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    [self.imageContainerView addSubview:_sourceImageView];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.backgroundColor = [self.backgroundColor colorWithAlphaComponent:1];
        self.sourceImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        self.sourceImageView.center = self.imageContainerView.center;
    } completion:nil];
}

- (void)hide{
    CGRect rect = [self.sourceImageView convertRect:self.sourceImageView.bounds toView:self.containerView];
    [self.sourceImageView removeFromSuperview];
    self.sourceImageView.frame = rect;
    [self.containerView addSubview:self.sourceImageView];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0];
        self.sourceImageView.frame = self.startAnimationRect;
    } completion:^(BOOL finished) {
        self.isShow = NO;
        self.scrollView.zoomScale = 1;
        self.imageContainerView.transform = CGAffineTransformIdentity;
        [self.sourceImageView removeFromSuperview];
        [self.scrollView removeFromSuperview];
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
        self.sourceImageView.frame = self.startRect;
        [self.sourceImageViewSuperView addSubview:self.sourceImageView];
    }];
}

- (void)setBrowseEnabled:(BOOL)browseEnabled{
    [self.sourceImageView removeGestureRecognizer:_tapAction];
    [self.sourceImageView removeGestureRecognizer:_doubleTapAction];
    if(browseEnabled){
        if(!_tapAction){
            _tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionEvent)];
            _tapAction.numberOfTapsRequired = 1;
        }
        if(!_doubleTapAction){
            _doubleTapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scroll_doubleTapAction:)];
            _doubleTapAction.numberOfTapsRequired = 2;
        }
        
        [_tapAction requireGestureRecognizerToFail:_doubleTapAction];
        [self.sourceImageView addGestureRecognizer:_tapAction];
        [self.sourceImageView addGestureRecognizer:_doubleTapAction];
    }
    _browseEnabled = browseEnabled;
}

- (void)tapActionEvent{
    if(_isShow){
        [self hide];
    }else{
        [self show];
    }
}

- (void)configScrollView{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.containerView.frame];
    _scrollView.backgroundColor = _backgroundColor;
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 4;
    _scrollView.contentSize = self.containerView.size;
    
    UITapGestureRecognizer *one_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scroll_tapAction)];
    one_tap.numberOfTapsRequired = 1;
    UITapGestureRecognizer *double_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scroll_doubleTapAction:)];
    double_tap.numberOfTapsRequired = 2;
    UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(scroll_LongPressedAction:)];
    [one_tap requireGestureRecognizerToFail:double_tap];
    [_scrollView addGestureRecognizer:one_tap];
    [_scrollView addGestureRecognizer:double_tap];
    [_scrollView addGestureRecognizer:longPressed];
    
    _imageContainerView = [[UIView alloc] init];
    _imageContainerView.clipsToBounds = YES;
    _imageContainerView.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:_imageContainerView];
}

- (UIView *)containerView{
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appdelegate.window;
}

- (CGRect)imageViewFrameOnKeyWindow{
    return [self.sourceImageView convertRect:self.sourceImageView.bounds toView:self.containerView];
}

#pragma mark - scrollView some method
- (void)scroll_tapAction{
    [self hide];
}

- (void)scroll_doubleTapAction:(UITapGestureRecognizer *)tap{
    if(!_isShow)return;
        
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageContainerView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.scrollView.width /newZoomScale;
        CGFloat ysize = self.scrollView.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)scroll_LongPressedAction:(UILongPressGestureRecognizer *)longPressed{
    if(longPressed.state == UIGestureRecognizerStateBegan){
        if(_longPressedBlock){
            _longPressedBlock();
        }
    }
}

#pragma mark - scrollview delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end

@implementation UIImageView (browse)

- (FCImageViewScaleExtension *)extension{
    FCImageViewScaleExtension *extension = objc_getAssociatedObject(self, _cmd);
    if(!extension){
        extension = [[FCImageViewScaleExtension alloc] init];
        extension.sourceImageView = self;
        objc_setAssociatedObject(self, _cmd, extension, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return extension;
}

- (void)setBrowseEnabled:(BOOL)browseEnabled{
    self.userInteractionEnabled = browseEnabled;
    [self extension].browseEnabled = browseEnabled;
}

- (BOOL)browseEnabled{
    return [self extension].browseEnabled;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    [self extension].backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor{
    return [self extension].backgroundColor;
}

- (longPressedAction)longPressedBlock{
    return [self extension].longPressedBlock;
}

- (void)setLongPressedBlock:(longPressedAction)longPressedBlock{
    [self extension].longPressedBlock = longPressedBlock;
}

@end
