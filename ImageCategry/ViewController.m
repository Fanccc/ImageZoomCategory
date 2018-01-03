//
//  ViewController.m
//  ImageCategry
//
//  Created by fanchuan on 2017/6/20.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+Zoom.h"
#import "ATableViewCell.h"
#import "FCImage.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

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
    _imageView.image = [UIImage imageNamed:@"test_image"];
    //test_image
    //longImage
    //longImage_v
    _imageView.browseEnabled = YES;
    
    return;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 340, self.view.frame.size.width, self.view.frame.size.height - 340) style:UITableViewStylePlain];
    [_tableView registerClass:[ATableViewCell class] forCellReuseIdentifier:@"a"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scroll");
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"a" forIndexPath:indexPath];
    return cell;
}


@end
