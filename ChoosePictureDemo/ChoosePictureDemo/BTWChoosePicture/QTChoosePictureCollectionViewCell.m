//
//  ChoosePictureCollectionViewCell.m
//  ChoosePictureDemo
//
//  Created by QT on 2017/7/27.
//  Copyright © 2017年 qt. All rights reserved.
//

#import "QTChoosePictureCollectionViewCell.h"

@interface QTChoosePictureCollectionViewCell ()

@property (nonatomic, strong) UIImageView *pictureImageView;

@end

@implementation QTChoosePictureCollectionViewCell

- (UIImageView *)pictureImageView {
    if (_pictureImageView == nil) {
        _pictureImageView = [[UIImageView alloc] init];
    }
    return _pictureImageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.pictureImageView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews
{
    self.pictureImageView.frame = self.bounds;
}

- (void)setCellImg:(UIImage *)cellImg
{
    _cellImg = cellImg;
    
    self.pictureImageView.image = cellImg;
}

@end
