//
//  ATableViewCell.m
//  ImageCategry
//
//  Created by fanchuan on 2017/6/21.
//  Copyright © 2017年 fanchuan. All rights reserved.
//

#import "ATableViewCell.h"
#import "UIImageView+Scale.h"

@implementation ATableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        UIImageView *_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [self.contentView addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.image = [UIImage imageNamed:@"test_image"];
        _imageView.allowScale = YES;
    }
    return self;
}

@end
