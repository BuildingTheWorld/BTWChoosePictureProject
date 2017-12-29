//
//  QTImagePickCell.m
//  QingTengShe
//
//  Created by QT on 2017/11/24.
//

#import "QTImagePickCell.h"

@interface QTImagePickCell ()

@property (nonatomic, strong) UIImageView *pickImageView;

@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation QTImagePickCell

#pragma mark - lazy

- (UIImageView *)pickImageView {
    if (_pickImageView == nil) {
        _pickImageView = [[UIImageView alloc] init];
        _pickImageView.backgroundColor = [UIColor lightGrayColor];
    }
    return _pickImageView;
}

- (UIButton *)selectButton {
    if (_selectButton == nil) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"yy_cart_choose_normal"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"yy_cart_choose_select"] forState:UIControlStateSelected];
    }
    return _selectButton;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.pickImageView];
        [self.contentView addSubview:self.selectButton];
        
        [self.pickImageView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        [self.selectButton makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.offset(18 * SCALE_6S_WIDTH);
            make.top.offset(2 * SCALE_6S_WIDTH);
            make.right.offset(-2 * SCALE_6S_WIDTH);
        }];
    }
    return self;
}

#pragma mark - setter

- (void)setPickAsset:(PHAsset *)pickAsset
{
    _pickAsset = pickAsset;
    
    PHImageRequestOptions *pickOptions = [[PHImageRequestOptions alloc] init];
    pickOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGFloat scaleFloat = [UIScreen mainScreen].scale;
    
    __weak typeof(self) weakSelf = self;
    
    [[PHImageManager defaultManager] requestImageForAsset:pickAsset
                                               targetSize:CGSizeMake(self.bounds.size.width * scaleFloat, self.bounds.size.height * scaleFloat)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:pickOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (result != nil) {
            weakSelf.pickImageView.image = result;
        }
        
    }];
    
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected == YES) {
        self.selectButton.selected = YES;
    }
    if (selected == NO) {
        self.selectButton.selected = NO;
    }
}

@end



