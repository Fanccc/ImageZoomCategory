//
//  UIImageView+Scale.m
//  ImageCategry
//
//  Created by fanchuan on 2017/6/20.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "UIImageView+Zoom.h"
#import "AppDelegate.h"
#import <objc/runtime.h>


#define stringFromPoint(x) NSStringFromCGPoint(x)
#define heightFromFrame(x) x.frame.size.height
#define widthFromFrame(x)  x.frame.size.width
#define widthFromRect(x)   x.size.width
#define heightFromRect(x)   x.size.height


//private class
@interface FCImageViewScaleExtension : NSObject<UIScrollViewDelegate>

@property (nonatomic, assign) BOOL allowScale;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIImageView *originalImageView;
@property (nonatomic, strong) UIView *originalImageViewSuperView;
@property (nonatomic, assign) CGRect startRect;
@property (nonatomic, assign) CGRect startAnimationRect;

@property (nonatomic, strong) UIScrollView *scrollView;

//手势
@property (nonatomic, strong) UITapGestureRecognizer *tapAction;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapAction;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, copy) longPressedAction longPressedBlock;

@property (nonatomic, assign) BOOL isShow;

@property (nonatomic, assign) BOOL isPan;

@end

@implementation FCImageViewScaleExtension

- (instancetype)init{
    if(self = [super init]){
        _bgColor = [UIColor blackColor];
        _isShow = NO;
    }
    return self;
}

- (void)show{
    if(!_scrollView){
        [self configScrollView];
    }
    
    _isShow = YES;
    
    _startRect = _originalImageView.frame;
    _startAnimationRect = [self imageViewFrameOnKeyWindow];
    
    self.originalImageViewSuperView = _originalImageView.superview;
    [_originalImageView removeFromSuperview];
    _originalImageView.frame = _startAnimationRect;
    [[self addToView] addSubview:self.scrollView];
    [[self addToView] addSubview:_originalImageView];
    self.scrollView.backgroundColor = [_bgColor colorWithAlphaComponent:0];
    
    UIView *addView = [self addToView];
    CGSize imageSize = CGSizeMake(CGRectGetWidth(addView.frame), CGRectGetWidth(addView.frame)/(_originalImageView.image.size.width/_originalImageView.image.size.height));
    
    self.scrollView.contentSize = CGSizeMake(widthFromFrame([self addToView]), MAX(imageSize.height, heightFromFrame([self addToView])));
    
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.backgroundColor = [self.bgColor colorWithAlphaComponent:1];
        self.originalImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        self.originalImageView.center = CGPointMake(self.scrollView.contentSize.width/2, self.scrollView.contentSize.height/2);
    } completion:^(BOOL finished) {
        [self.originalImageView removeFromSuperview];
        [self.scrollView addSubview:self.originalImageView];
        self.originalImageView.center = CGPointMake(self.scrollView.contentSize.width/2, self.scrollView.contentSize.height/2);
    }];
}

- (void)hide{
    CGRect rect = [self.originalImageView convertRect:self.originalImageView.bounds toView:[self addToView]];
    [self.originalImageView removeFromSuperview];
    self.originalImageView.frame = rect;
    [[self addToView] addSubview:self.originalImageView];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.backgroundColor = [self.bgColor colorWithAlphaComponent:0];
        self.originalImageView.frame = self.startAnimationRect;
    } completion:^(BOOL finished) {
        self.isShow = NO;
        self.scrollView.zoomScale = 1;
        self.originalImageView.transform = CGAffineTransformIdentity;
        [self.originalImageView removeFromSuperview];
        [self.scrollView removeFromSuperview];
        self.originalImageView.frame = self.startRect;
        [self.originalImageViewSuperView addSubview:self.originalImageView];
    }];
}


- (void)setAllowScale:(BOOL)allowScale{
    [self.originalImageView removeGestureRecognizer:_tapAction];
    [self.originalImageView removeGestureRecognizer:_doubleTapAction];
    if(allowScale){
        if(!_tapAction){
            _tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActionEvent)];
            _tapAction.numberOfTapsRequired = 1;
        }
        if(!_doubleTapAction){
            _doubleTapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scroll_doubleTapAction:)];
            _doubleTapAction.numberOfTapsRequired = 2;
        }
        
        [_tapAction requireGestureRecognizerToFail:_doubleTapAction];
        [self.originalImageView addGestureRecognizer:_tapAction];
        [self.originalImageView addGestureRecognizer:_doubleTapAction];
    }
    _allowScale = allowScale;
}

- (void)tapActionEvent{
    if(_isShow){
        [self hide];
    }else{
        [self show];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)pan{
    if(!_isShow)return;
    
    UIView *panView = pan.view;
    
    if(pan.state == UIGestureRecognizerStateBegan){
        self.isPan = YES;
    }
    
    CGPoint position = [pan translationInView:panView];
    self.originalImageView.transform = CGAffineTransformTranslate(self.originalImageView.transform, position.x, position.y);
    [pan setTranslation:CGPointZero inView:panView];
    
    CGPoint imageCenter = [self.originalImageView convertPoint:CGPointMake(self.originalImageView.bounds.size.width/2, self.originalImageView.bounds.size.height/2) toView:[self addToView]];
    
    CGFloat offsetY = imageCenter.y;
    CGFloat offsetValue = offsetY - heightFromFrame(self.scrollView)/2;
    CGFloat bili = fabs(offsetValue/(heightFromFrame(self.scrollView)/2));
    CGFloat currentValue = 1 - bili >= 0?1-bili:0;
    self.scrollView.backgroundColor = [self.bgColor colorWithAlphaComponent:currentValue];
    
    [self.scrollView setZoomScale:0.8 animated:YES];
    
    if(pan.state == UIGestureRecognizerStateEnded){
        self.isPan = NO;
        if(currentValue <= 0.3f){
            [self hide];
        }else{
            [UIView animateWithDuration:0.3f animations:^{
                self.scrollView.backgroundColor = [self.bgColor colorWithAlphaComponent:1];
                self.originalImageView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

- (void)configScrollView{
    _scrollView = [[UIScrollView alloc] initWithFrame:[self addToView].frame];
    _scrollView.backgroundColor = _bgColor;
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 0.8;
    _scrollView.maximumZoomScale = 4;
    _scrollView.contentSize = [self addToView].frame.size;
    _scrollView.bouncesZoom = NO;
    
    UITapGestureRecognizer *one_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scroll_tapAction)];
    one_tap.numberOfTapsRequired = 1;
    UITapGestureRecognizer *double_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scroll_doubleTapAction:)];
    double_tap.numberOfTapsRequired = 2;
    UILongPressGestureRecognizer *longPressed = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(scroll_LongPressedAction:)];
    [one_tap requireGestureRecognizerToFail:double_tap];
    [_scrollView addGestureRecognizer:one_tap];
    [_scrollView addGestureRecognizer:double_tap];
    [_scrollView addGestureRecognizer:longPressed];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [_scrollView addGestureRecognizer:_panGesture];
}

- (UIView *)addToView{
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appdelegate.window;
}

- (CGRect)imageViewFrameOnKeyWindow{
    return [self.originalImageView convertRect:self.originalImageView.bounds toView:[self addToView]];
}

#pragma mark - scrollView some method
- (void)scroll_tapAction{
    [self hide];
}

- (void)scroll_doubleTapAction:(UITapGestureRecognizer *)tap{
    if(_isShow){
        if (_scrollView.zoomScale > 1.0) {
            [_scrollView setZoomScale:1.0 animated:YES];
        } else {
            CGPoint touchPoint = [tap locationInView:self.originalImageView];
            CGFloat newZoomScale = _scrollView.maximumZoomScale;
            CGFloat xsize = self.scrollView.frame.size.width / newZoomScale;
            CGFloat ysize = self.scrollView.frame.size.height / newZoomScale;
            [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        }
    }
}

- (void)scroll_LongPressedAction:(UILongPressGestureRecognizer *)longPressed{
    if(longPressed.state == UIGestureRecognizerStateBegan){
        if(_longPressedBlock){
            _longPressedBlock();
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _originalImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _originalImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if(self.isPan)return;
    if(scale < 1){
        [scrollView setZoomScale:1 animated:YES];
    }
}


@end


@implementation UIImageView (Zoom)

- (FCImageViewScaleExtension *)extension{
    FCImageViewScaleExtension *extension = objc_getAssociatedObject(self, _cmd);
    if(!extension){
        extension = [[FCImageViewScaleExtension alloc] init];
        extension.originalImageView = self;
        objc_setAssociatedObject(self, _cmd, extension, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return extension;
}

- (void)setAllowScale:(BOOL)allowScale{
    self.userInteractionEnabled = allowScale;
    [self extension].allowScale = allowScale;
}

- (BOOL)allowScale{
    return [self extension].allowScale;
}

- (void)setBgColor:(UIColor *)bgColor{
    [self extension].bgColor = bgColor;
}

- (UIColor *)bgColor{
    return [self extension].bgColor;
}

- (longPressedAction)longPressedBlock{
    return [self extension].longPressedBlock;
}

- (void)setLongPressedBlock:(longPressedAction)longPressedBlock{
    [self extension].longPressedBlock = longPressedBlock;
}

@end
