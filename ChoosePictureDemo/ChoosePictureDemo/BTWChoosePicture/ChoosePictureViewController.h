//
//  ViewController.h
//  ChoosePictureDemo
//
//  Created by QT on 2017/7/27.
//  Copyright © 2017年 qt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChoosePictureViewController : UIViewController

@property (nonatomic, strong) UIImage *addImage;

@property (nonatomic, assign) CGSize imgItemSize;

@property (nonatomic, assign) NSInteger CPMaxCount;

@property (nonatomic, strong) NSMutableArray *uploadImageArray;

@end

