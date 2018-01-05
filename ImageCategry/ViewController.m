//
//  ViewController.m
//  ImageCategry
//
//  Created by fanchuan on 2017/6/20.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+Browse.h"


@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 30, 300, 300)];
    [self.view addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.browseBackgroundColor = [UIColor grayColor];
    _imageView.image = [UIImage imageNamed:@"test_image"];
    //test_image
    //longImage
    //longImage_v
    _imageView.browseEnabled = YES;


}

@end
