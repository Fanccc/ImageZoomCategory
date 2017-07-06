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
#define heightFromRect(x)  x.size.height


//private class
@interface FCImageViewScaleExtension : NSObject<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL allowScale;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIImageView *originalImageView;
@property (nonatomic, strong) UIView *originalImageViewSuperView;
@property (nonatomic, assign) CGRect startRect;
@property (nonatomic, assign) CGRect startAnimationRect;

@property (nonatomic, strong) UIScrollView *scrollView;

//手势
@property (nonatomic, strong) UITapGestureRecognizer *tapAction;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapAction;

@property (nonatomic, copy) longPressedAction longPressedBlock;

@property (nonatomic, assign) BOOL isShow;

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
    _originalImageViewSuperView = _originalImageView.superview;
    
    UIView *addView = [self addToView];
    [_originalImageView removeFromSuperview];
    _originalImageView.frame = _startAnimationRect;
    [addView addSubview:self.scrollView];
    self.scrollView.backgroundColor = [_bgColor colorWithAlphaComponent:0];
    
    CGSize imageSize = CGSizeMake(widthFromFrame(addView), widthFromFrame(addView)/(_originalImageView.image.size.width/_originalImageView.image.size.height));
    CGSize contentSize = CGSizeMake(widthFromFrame(addView), MAX(imageSize.height, heightFromFrame(addView)));
    self.scrollView.contentSize = contentSize;
    self.imageContainerView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    [self.imageContainerView addSubview:_originalImageView];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.backgroundColor = [self.bgColor colorWithAlphaComponent:1];
        self.originalImageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        self.originalImageView.center = self.imageContainerView.center;
    } completion:nil];
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
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
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

- (void)configScrollView{
    _scrollView = [[UIScrollView alloc] initWithFrame:[self addToView].frame];
    _scrollView.backgroundColor = _bgColor;
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 4;
    _scrollView.contentSize = [self addToView].frame.size;
    
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
    [_scrollView addSubview:_imageContainerView];
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
    if(!_isShow)return;
        
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.originalImageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
            CGFloat xsize = self.scrollView.frame.size.width /newZoomScale;
        CGFloat ysize = self.scrollView.frame.size.height / newZoomScale;
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width) ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height) ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
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
