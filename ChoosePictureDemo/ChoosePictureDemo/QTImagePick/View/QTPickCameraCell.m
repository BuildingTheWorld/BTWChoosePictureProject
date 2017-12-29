//
//  QTPickCameraCell.m
//  QingTengShe
//
//  Created by QT on 2017/11/30.
//

#import "QTPickCameraCell.h"

@interface QTPickCameraCell ()

@property (nonatomic, strong) UIImageView *cameraImageView;

@end

@implementation QTPickCameraCell

#pragma mark - lazy

- (UIImageView *)cameraImageView {
    if (_cameraImageView == nil) {
        _cameraImageView = [[UIImageView alloc] init];
        _cameraImageView.image = [UIImage imageNamed:@"yy_pickImg_camera"];
    }
    return _cameraImageView;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.cameraImageView];
        [self.cameraImageView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }
    return self;
}

@end
