//
//  ViewController.m
//  ChoosePictureDemo
//
//  Created by QT on 2017/7/27.
//  Copyright © 2017年 qt. All rights reserved.
//

#import "ChoosePictureViewController.h"

#import "QTChoosePictureCollectionViewCell.h"

#import <Photos/Photos.h>

#import "QTImagePickController.h"

//#import "QTNavigationController.h"

@interface ChoosePictureViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UICollectionView *CPCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *CPFlowLayout;
@property (nonatomic, strong) NSMutableArray *modelArray;

@end

@implementation ChoosePictureViewController

- (UICollectionViewFlowLayout *)CPFlowLayout {
    if (_CPFlowLayout == nil) {
        _CPFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        _CPFlowLayout.itemSize = self.imgItemSize;
        NSInteger singleLineMaxCount = self.view.bounds.size.width / self.imgItemSize.width;
        CGFloat interItemSpace = (self.view.bounds.size.width - self.imgItemSize.width * singleLineMaxCount) / (singleLineMaxCount + 1);
        self.CPFlowLayout.sectionInset = UIEdgeInsetsMake(interItemSpace, interItemSpace, interItemSpace, interItemSpace);
        self.CPFlowLayout.minimumLineSpacing = interItemSpace;
        self.CPFlowLayout.minimumInteritemSpacing = interItemSpace;
    }
    return _CPFlowLayout;
}

- (UICollectionView *)CPCollectionView {
    if (_CPCollectionView == nil) {
        _CPCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.CPFlowLayout];
        _CPCollectionView.dataSource = self;
        _CPCollectionView.delegate = self;
        _CPCollectionView.backgroundColor = [UIColor whiteColor];
        [_CPCollectionView registerClass:[QTChoosePictureCollectionViewCell class] forCellWithReuseIdentifier:@"CPCell"];
        _CPCollectionView.showsHorizontalScrollIndicator = NO;
        _CPCollectionView.showsVerticalScrollIndicator = NO;
    }
    return _CPCollectionView;
}

- (NSMutableArray *)modelArray {
    if (_modelArray == nil) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

- (NSMutableArray *)uploadImageArray {
    if (_uploadImageArray == nil) {
        _uploadImageArray = [NSMutableArray array];
    }
    return _uploadImageArray;
}

#pragma mark - setter

- (void)setAddImage:(UIImage *)addImage
{
    _addImage = addImage;
    
    [self.modelArray addObject:addImage]; // ---关键代码---
}

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = normalGreenColor;
    
    [self.view addSubview:self.CPCollectionView];
    [self.CPCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self addNotificationObserver];
}


- (void)dealloc {
    
    [self removeNotificationObserver];
}

#pragma mark - notification

- (void)addNotificationObserver
{
    __weak typeof(self) weakSelf = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationNamePickImage object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        NSArray *tempArray = note.userInfo[kNotificationInfoKeyPickImage];
        
        [weakSelf.uploadImageArray addObjectsFromArray:tempArray];
        
        NSRange tempRange = NSMakeRange(self.modelArray.count - 1, tempArray.count);
        NSIndexSet *tempIndexSet = [NSIndexSet indexSetWithIndexesInRange:tempRange];
        [self.modelArray insertObjects:tempArray atIndexes:tempIndexSet]; // ---关键代码---
        
        [self.CPCollectionView reloadData];
    }];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNamePickImage object:nil];
}

#pragma mark - collection data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MIN(self.modelArray.count, self.CPMaxCount); // ---关键代码---
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QTChoosePictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPCell" forIndexPath:indexPath];
    
    cell.cellImg = self.modelArray[indexPath.row];
    
    return cell;
}

#pragma mark - collection delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    
    if (indexPath.row == (self.modelArray.count - 1)) // 点击的是加号
    {
        [self getUserPhotoAuthorizationStatus];
    }
    else // 点击的是图片
    {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"确定要删除照片吗?" message:@"删除操作无法撤销" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf.modelArray removeObjectAtIndex:indexPath.row]; // ---关键代码---
            [weakSelf.uploadImageArray removeObjectAtIndex:indexPath.row];
            [weakSelf.CPCollectionView reloadData];
        }];
        
        [alertC addAction:cancelAction];
        [alertC addAction:deleteAction];
        
        [self presentViewController:alertC animated:YES completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSData *imageData = UIImageJPEGRepresentation(info[UIImagePickerControllerEditedImage], 0.8);
    
    [self.uploadImageArray addObject:imageData];
    
    UIImage * newImage = [UIImage imageWithData:imageData];
    
    [self.modelArray insertObject:newImage atIndex:(self.modelArray.count - 1)]; // ---关键代码---

    [self.CPCollectionView reloadData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 获取 User Photo 权限
- (void)getUserPhotoAuthorizationStatus
{
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    
    if (photoStatus == PHAuthorizationStatusAuthorized)
    {
        [self showImagePickVC];
    }
    else if (photoStatus == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self showImagePickVC];
                });
            }
        }];
    }
    else
    {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"请开启照片权限" message:@"请在'设置'-'隐私'-'照片'中,找到青藤乐购更改" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertC addAction:cancelAction];
        [self presentViewController:alertC animated:YES completion:nil];
    }
}

- (void)showImagePickVC
{
    QTImagePickController *imagePickVC = [[QTImagePickController alloc] init];
    imagePickVC.maxSelectedImageCount = 8;
    QTNavigationController *navC = [[QTNavigationController alloc] initWithRootViewController:imagePickVC];
    [self presentViewController:navC animated:YES completion:nil];
    
}

@end
