//
//  QTThumbnailCell.m
//  QingTengShe
//
//  Created by QT on 2017/11/29.
//

#import "QTThumbnailCell.h"

@interface QTThumbnailCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;

@end

@implementation QTThumbnailCell

#pragma mark - lazy

- (UIImageView *)thumbnailImageView {
    if (_thumbnailImageView == nil) {
        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.backgroundColor = [UIColor lightGrayColor];
    }
    return _thumbnailImageView;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.thumbnailImageView];
        [self.thumbnailImageView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }
    return self;
}

#pragma mark - setter

- (void)setThumbnailAsset:(PHAsset *)thumbnailAsset
{
    _thumbnailAsset = thumbnailAsset;
    
    PHImageRequestOptions *thumbnailOptions = [[PHImageRequestOptions alloc] init];
    thumbnailOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    thumbnailOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGFloat scaleFloat = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(self.bounds.size.width * scaleFloat, self.bounds.size.height * scaleFloat);
    
    __weak typeof(self) weakSelf = self;
    
    [[PHImageManager defaultManager] requestImageForAsset:thumbnailAsset
                                               targetSize:targetSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:thumbnailOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
       
        if (result != nil) {
            weakSelf.thumbnailImageView.image = result;
        }        
    }];
    
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected == YES) {
        self.thumbnailImageView.layer.borderColor = [UIColor blackColor].CGColor;
        self.thumbnailImageView.layer.borderWidth = 3 * SCALE_6S_WIDTH;
        
    } else {
        self.thumbnailImageView.layer.borderWidth = 0.0;
        self.thumbnailImageView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
