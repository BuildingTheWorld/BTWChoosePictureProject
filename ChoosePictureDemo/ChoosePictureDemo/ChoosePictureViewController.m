//
//  ViewController.m
//  ChoosePictureDemo
//
//  Created by QT on 2017/7/27.
//  Copyright © 2017年 qt. All rights reserved.
//

#import "ChoosePictureViewController.h"

#import "QTChoosePictureCollectionViewCell.h"


@interface ChoosePictureViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic, strong) UICollectionView *CPCollectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *CPFlowLayout;

@property (nonatomic, strong) NSMutableArray *modelArray;

@end



@implementation ChoosePictureViewController


- (UICollectionViewFlowLayout *)CPFlowLayout
{
    if (_CPFlowLayout == nil) {
        
        _CPFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        _CPFlowLayout.itemSize = self.imgItemSize;
        
        _CPFlowLayout.minimumInteritemSpacing = self.CPMinimumInteritemSpacing;
    }
    
    return _CPFlowLayout;
}


- (UICollectionView *)CPCollectionView
{
    if (_CPCollectionView == nil) {
        
        _CPCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.CPFlowLayout];
        
        _CPCollectionView.dataSource = self;
        _CPCollectionView.delegate = self;
        
        _CPCollectionView.backgroundColor = [UIColor whiteColor];
        
        [_CPCollectionView registerClass:[QTChoosePictureCollectionViewCell class] forCellWithReuseIdentifier:@"CPCell"];
        
    }
    
    return _CPCollectionView;
}


- (NSMutableArray *)modelArray
{
    if (_modelArray == nil)
    {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

- (NSMutableArray *)uploadImageArray{
    if (_uploadImageArray == nil) {
        _uploadImageArray = [NSMutableArray array];
    }
    return _uploadImageArray;
}


- (void)setAddImage:(UIImage *)addImage
{
    _addImage = addImage;
    
    [self.modelArray addObject:addImage]; // ---关键代码---
}


#pragma mark - view life cycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.view addSubview:self.CPCollectionView];
    
    [self.CPCollectionView makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.equalTo(self.view);
    }];
    
}


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


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    __weak typeof(self) weakSelf = self;
    
    
    if (indexPath.row == (self.modelArray.count - 1)) // 点击的是加号
    {
        
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"请选择图片来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从图库选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                
                UIImagePickerController *imgPickerC = [[UIImagePickerController alloc] init];
                
                imgPickerC.delegate = weakSelf;
                imgPickerC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imgPickerC.allowsEditing = YES;
                
                [weakSelf presentViewController:imgPickerC animated:YES completion:nil];
            }
            
        }];
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alertC addAction:cancelAction];
        [alertC addAction:cameraAction];
        [alertC addAction:photoAction];
        
        [self presentViewController:alertC animated:YES completion:nil];
        
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


@end
