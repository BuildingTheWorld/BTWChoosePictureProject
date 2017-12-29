//
//  QTImagePickController.m
//  QingTengShe
//
//  Created by QT on 2017/11/23.
//

#import "QTImagePickController.h"

#import "QTPickCameraCell.h"
#import "QTImagePickCell.h"

#import <Photos/Photos.h>

#import "QTImageDisplayController.h"

static NSString * const kQTPickCameraCellID = @"kQTPickCameraCellID";
static NSString * const kQTImagePickCellID = @"kQTImagePickCellID";

static CGFloat const kItemMargin = 2;

@interface QTImagePickController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *imagePickFlowLayout;
@property (nonatomic, strong) UICollectionView *imagePickCollectionView;
@property (nonatomic, strong) PHFetchResult *dataResult;
@property (nonatomic, assign) CGFloat itemWH;

@property (nonatomic, strong) UIImagePickerController *cameraPickerC;

@end

@implementation QTImagePickController

#pragma mark - lazy

- (UICollectionViewFlowLayout *)imagePickFlowLayout {
    if (_imagePickFlowLayout == nil) {
        _imagePickFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _imagePickFlowLayout.minimumLineSpacing = kItemMargin;
        _imagePickFlowLayout.minimumInteritemSpacing = kItemMargin;
        CGFloat itemWH = (SCREEN_WIDTH - 3 * kItemMargin) / 4;
        self.itemWH = itemWH;
        _imagePickFlowLayout.itemSize = CGSizeMake(itemWH, itemWH);
    }
    return _imagePickFlowLayout;
}

- (UICollectionView *)imagePickCollectionView {
    if (_imagePickCollectionView == nil) {
        _imagePickCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.imagePickFlowLayout];
        _imagePickCollectionView.dataSource = self;
        _imagePickCollectionView.delegate = self;
        _imagePickCollectionView.allowsMultipleSelection = YES;
        [_imagePickCollectionView registerClass:[QTImagePickCell class] forCellWithReuseIdentifier:kQTImagePickCellID];
        [_imagePickCollectionView registerClass:[QTPickCameraCell class] forCellWithReuseIdentifier:kQTPickCameraCellID];
    }
    return _imagePickCollectionView;
}

- (UIImagePickerController *)cameraPickerC {
    if (_cameraPickerC == nil) {
        _cameraPickerC = [[UIImagePickerController alloc] init];
        _cameraPickerC.delegate = self;
        _cameraPickerC.sourceType = UIImagePickerControllerSourceTypeCamera;
        _cameraPickerC.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    return _cameraPickerC;
}

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self loadPhoto];
    
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - setUpUI

- (void)setUpUI
{
    self.navigationItem.title = @"相机胶卷";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(leftItemClick)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.imagePickCollectionView];
    [self.imagePickCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(kStatusBarAndNavigationBarHeight);
        make.left.bottom.right.offset(0);
    }];
    
    if (@available(iOS 11.0, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - load Photo

- (void)loadPhoto
{
    NSPredicate *pickPredicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    NSSortDescriptor *pickDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    
    PHFetchOptions *imageOptions = [[PHFetchOptions alloc] init];
    imageOptions.predicate = pickPredicate;
    imageOptions.sortDescriptors = @[pickDescriptor];
    
    PHFetchResult *dataResult = [PHAsset fetchAssetsWithOptions:imageOptions];
    self.dataResult = dataResult;
}

#pragma mark - imagePickCollectionView data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (self.dataResult.count + 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    if ([indexPath isEqual:firstIndexPath]) {
        QTPickCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQTPickCameraCellID forIndexPath:indexPath];
        
        return cell;
    } else {
        QTImagePickCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQTImagePickCellID forIndexPath:indexPath];
        
        cell.pickAsset = self.dataResult[indexPath.row - 1];
        
        return cell;
    }
}

#pragma mark - imagePickCollectionView delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.imagePickCollectionView.indexPathsForSelectedItems.count >= self.maxSelectedImageCount) {
        
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabel.text = @"最多选择8张照片哦~";
        [hud hideAnimated:YES afterDelay:1.5];
        return NO;
    } else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    if ([indexPath isEqual:firstIndexPath]) {
        
        [self getUserCameraAuthorizationStatus];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *tempImage = info[UIImagePickerControllerOriginalImage];
    
    UIImageWriteToSavedPhotosAlbum(tempImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SEL

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self loadPhoto];
    
    [self.imagePickCollectionView reloadData];
}

- (void)leftItemClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightItemClick
{
    NSArray *selectArray = self.imagePickCollectionView.indexPathsForSelectedItems;
    
    NSMutableIndexSet *selectIndexSet = [NSMutableIndexSet indexSet];
    
    [selectArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath *tempIndexPath = obj;
        [selectIndexSet addIndex:tempIndexPath.row - 1];
    }];
    
    NSArray *displayArray = [self.dataResult objectsAtIndexes:selectIndexSet];
    
    if (displayArray.count == 0) {
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabel.text = @"最少选择1张照片哦~";
        [hud hideAnimated:YES afterDelay:1.5];
    } else {
        QTImageDisplayController *clipVC = [[QTImageDisplayController alloc] init];
        clipVC.displayArray = displayArray;
        [self.navigationController pushViewController:clipVC animated:YES];
    }
    
}

#pragma mark - 私有方法

/// 获取 User Camera 权限

- (void)getUserCameraAuthorizationStatus
{
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (cameraStatus == AVAuthorizationStatusAuthorized) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
            {
                [self presentViewController:self.cameraPickerC animated:YES completion:nil];
            } else {
                [self showMessage:@"摄像头不可用"];
            }
        } else {
            [self showMessage:@"摄像头不可用"];
        }
    } else if (cameraStatus == AVAuthorizationStatusNotDetermined) {
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
            if (granted == YES) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
                        {
                            [self presentViewController:self.cameraPickerC animated:YES completion:nil];
                        } else {
                            [self showMessage:@"摄像头不可用"];
                        }
                    } else {
                        [self showMessage:@"摄像头不可用"];
                    }
                });
            }
            
        }];
        
    } else {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"请开启相机权限" message:@"请在'设置'-'隐私'-'相机'中,找到青藤乐购更改" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertC addAction:cancelAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

@end
