
//
//  QTClipImageContainerView.m
//  QingTengShe
//
//  Created by QT on 2017/11/29.
//

#import "QTClipImageContainerView.h"

@interface QTClipImageContainerView () <UIScrollViewDelegate>

@end

@implementation QTClipImageContainerView

#pragma mark - lazy

- (UIScrollView *)clipScrollView {
    if (_clipScrollView == nil) {
        _clipScrollView = [[UIScrollView alloc] init];
        _clipScrollView.minimumZoomScale = 1.0;
        _clipScrollView.maximumZoomScale = 3.0;
        _clipScrollView.delegate = self;
        _clipScrollView.scrollsToTop = NO;
        _clipScrollView.bounces = NO;
        _clipScrollView.bouncesZoom = NO;
        _clipScrollView.showsHorizontalScrollIndicator = NO;
        _clipScrollView.showsVerticalScrollIndicator = NO;
    }
    return _clipScrollView;
}

- (UIImageView *)clipImageView {
    if (_clipImageView == nil) {
        _clipImageView = [[UIImageView alloc] init];
        _clipImageView.backgroundColor = [UIColor cyanColor];
    }
    return _clipImageView;
}

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        [self addSubview:self.clipScrollView];
        [self.clipScrollView makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.offset(SCREEN_WIDTH);
            make.center.offset(0);
        }];
    }
    return self;
}

#pragma mark - setter

- (void)setClipAsset:(PHAsset *)clipAsset
{
    _clipAsset = clipAsset;
    
    NSLog(@"sourceType = %lu", clipAsset.sourceType);
    
    __weak typeof(self) weakSelf = self;
    
    PHImageRequestOptions *clipOptions = [[PHImageRequestOptions alloc] init];
    clipOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    clipOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
    clipOptions.networkAccessAllowed = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    
    clipOptions.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            if (!error) {
                hud.mode = MBProgressHUDModeAnnularDeterminate;
                hud.detailsLabel.text = @"图片正在从iCloud中下载...";
                hud.progress = progress;
                if (progress == 1.0) {
                    [MBProgressHUD hideHUDForView:weakSelf animated:YES];
                }
            } else {
                hud.mode = MBProgressHUDModeText;
                hud.detailsLabel.text = @"图片从iCloud下载出错,请稍后再试";
                [hud hideAnimated:YES afterDelay:3.0];
            }
            
        });
        
    };
    
    [[PHImageManager defaultManager] requestImageForAsset:clipAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:clipOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:weakSelf animated:YES];
            
            if (result != nil) {
                CGSize clipImageViewSize = [weakSelf scaleImageViewSizeWithSize:result.size];
                
                [weakSelf.clipScrollView addSubview:weakSelf.clipImageView];
                [weakSelf.clipImageView makeConstraints:^(MASConstraintMaker *make) {
                    make.width.offset(clipImageViewSize.width);
                    make.height.offset(clipImageViewSize.height);
                    make.edges.offset(0);
                }];
                
                weakSelf.clipImageView.image = result;
                
            } else {
                
                MBProgressHUD *errorHUD = [MBProgressHUD showHUDAddedTo:weakSelf animated:YES];
                errorHUD.mode = MBProgressHUDModeText;
                errorHUD.detailsLabel.text = @"图片加载失败, 请稍后重试";
                [errorHUD hideAnimated:YES afterDelay:3.0];
                
                [weakSelf.clipScrollView addSubview:weakSelf.clipImageView];
                [weakSelf.clipImageView makeConstraints:^(MASConstraintMaker *make) {
                    make.width.height.offset(SCREEN_WIDTH);
                    make.center.offset(0);
                }];
            }
            
        });
        
    }];
    
}

#pragma mark - clipScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.clipImageView;
}

#pragma mark - 私有方法

/// 等比例缩放 ImageView 的 size , 以适应正方形的 ScrollView

- (CGSize)scaleImageViewSizeWithSize:(CGSize)imageSize
{
    CGFloat sourceWidth = imageSize.width;
    CGFloat sourceHeight = imageSize.height;
    
    CGFloat imageScale = 0.0;
    
    if (sourceWidth > sourceHeight) {
        imageScale = sourceHeight / SCREEN_WIDTH;
    } else {
        imageScale = sourceWidth / SCREEN_WIDTH;
    }
    
    CGFloat targetWidth = 0.0;
    CGFloat targetHeight = 0.0;
    
    targetWidth = sourceWidth / imageScale;
    targetHeight = sourceHeight / imageScale;
    
    return CGSizeMake(targetWidth, targetHeight);
}

@end
