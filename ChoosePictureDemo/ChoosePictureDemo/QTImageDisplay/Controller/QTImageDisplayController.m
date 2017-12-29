//
//  QTClipImageController.m
//  QingTengShe
//
//  Created by QT on 2017/11/24.
//

#import "QTImageDisplayController.h"

//#import "QTPostEssayController.h"
#import "QTClipImageContainerController.h"

#import "QTThumbnailCell.h"

#import "QTClipImageContainerView.h"

//#import "QTPinterestViewController.h"

static CGFloat const kItemSpace = 5;

static NSString * const kQTThumbnailCellID = @"kQTThumbnailCellID";

@interface QTImageDisplayController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *thumbnailFlowLayout;
@property (nonatomic, strong) UICollectionView *thumbnailCollectionView;
@property (nonatomic, assign) CGFloat itemWH;

@property (nonatomic, strong) QTClipImageContainerController *clipContainerVC;

@end

@implementation QTImageDisplayController

#pragma mark - lazy

- (UICollectionViewFlowLayout *)thumbnailFlowLayout {
    if (_thumbnailFlowLayout == nil) {
        _thumbnailFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWH = (SCREEN_WIDTH - 5 * kItemSpace) / 4;
        self.itemWH = itemWH;
        _thumbnailFlowLayout.itemSize = CGSizeMake(itemWH, itemWH);
        _thumbnailFlowLayout.sectionInset = UIEdgeInsetsMake(0, kItemSpace, 0, kItemSpace);
        _thumbnailFlowLayout.minimumLineSpacing = kItemSpace;
        _thumbnailFlowLayout.minimumInteritemSpacing = kItemSpace;
    }
    return _thumbnailFlowLayout;
}

- (UICollectionView *)thumbnailCollectionView {
    if (_thumbnailCollectionView == nil) {
        _thumbnailCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.thumbnailFlowLayout];
        _thumbnailCollectionView.dataSource = self;
        _thumbnailCollectionView.delegate = self;
        [_thumbnailCollectionView registerClass:[QTThumbnailCell class] forCellWithReuseIdentifier:kQTThumbnailCellID];
        _thumbnailCollectionView.showsHorizontalScrollIndicator = NO;
        _thumbnailCollectionView.showsVerticalScrollIndicator = NO;
        _thumbnailCollectionView.bounces = NO;
        _thumbnailCollectionView.backgroundColor = [UIColor whiteColor];
    }
    return _thumbnailCollectionView;
}

- (QTClipImageContainerController *)clipContainerVC {
    if (_clipContainerVC == nil) {
        _clipContainerVC = [[QTClipImageContainerController alloc] init];
        _clipContainerVC.containerArray = self.displayArray;
    }
    return _clipContainerVC;
}

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - setUpUI

- (void)setUpUI
{
    self.navigationItem.title = @"编辑照片";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addChildViewController:self.clipContainerVC];
    
    [self.view addSubview:self.clipContainerVC.view];
    [self.clipContainerVC.view makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(SCREEN_WIDTH);
        make.top.offset(kStatusBarAndNavigationBarHeight + 10 * SCALE_6S_HEIGHT);
        make.centerX.offset(0);
    }];
    
    [self.view addSubview:self.thumbnailCollectionView];
    [self.thumbnailCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(SCREEN_WIDTH);
        make.height.offset(self.itemWH * 2 + kItemSpace);
        make.centerX.offset(0);
        make.top.equalTo(self.clipContainerVC.view.mas_bottom).offset(10 * SCALE_6S_HEIGHT);
    }];
    
    if (@available(iOS 11.0, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (self.displayArray.count != 0) {
        NSIndexPath *selectIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.thumbnailCollectionView selectItemAtIndexPath:selectIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}



#pragma mark - thumbnailCollectionView data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.displayArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QTThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQTThumbnailCellID forIndexPath:indexPath];

    cell.thumbnailAsset = self.displayArray[indexPath.row];
    
    return cell;
}

#pragma mark - thumbnailCollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger item = indexPath.item;
    
    [self.clipContainerVC.containerScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * item, 0) animated:NO];
}

#pragma mark - SEL

- (void)rightItemClick
{
    [self imageClip];
}

#pragma mark - 图片裁剪

- (void)imageClip
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableArray *clipArray = [NSMutableArray array];
    
    for (UIView *tempView in self.clipContainerVC.containerScrollView.subviews) {
        if ([tempView isKindOfClass:[QTClipImageContainerView class]]) {
            
            QTClipImageContainerView *tempContainerView = (QTClipImageContainerView *)tempView;
            
            CGFloat contentWH = 0.0;
            CGFloat offsetX = tempContainerView.clipScrollView.contentOffset.x;
            CGFloat offsetY = tempContainerView.clipScrollView.contentOffset.y;
            CGFloat screenScale = [UIScreen mainScreen].scale;
            CGFloat zoomRatio = tempContainerView.clipScrollView.zoomScale;
            CGSize clipImageViewSize = tempContainerView.clipImageView.size;
            
            if (clipImageViewSize.width > clipImageViewSize.height) {
                contentWH = clipImageViewSize.height;
            } else {
                contentWH = clipImageViewSize.width;
            }
            
            NSLog(@"clipImageViewSizeW = %f--clipImageViewSizeH = %f--contentWH = %f--offsetX = %f--offsetY = %f--zoomRatio = %f--screenScale = %f",clipImageViewSize.width,clipImageViewSize.height,contentWH,offsetX,offsetY,zoomRatio,screenScale);
            
            CGSize contextSize = CGSizeMake(contentWH, contentWH);
            CGRect drawRect = CGRectMake(-offsetX * zoomRatio, -offsetY * zoomRatio, clipImageViewSize.width * zoomRatio, clipImageViewSize.height * zoomRatio);
            UIImage *drawImage = tempContainerView.clipImageView.image;
            
            UIGraphicsBeginImageContextWithOptions(contextSize, NO, 0);
            [drawImage drawInRect:drawRect];
            UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [clipArray addObject:clipImage];
        }
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSDictionary *notificationDict = @{
                                       kNotificationInfoKeyPickImage : clipArray
                                       };
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNamePickImage object:nil userInfo:notificationDict];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
