//
//  QTClipImageContainerController.m
//  QingTengShe
//
//  Created by QT on 2017/11/29.
//

#import "QTClipImageContainerController.h"

#import "QTClipImageContainerView.h"

#import <Photos/Photos.h>

@interface QTClipImageContainerController ()

@end

@implementation QTClipImageContainerController

#pragma mark - lazy

- (UIScrollView *)containerScrollView {
    if (_containerScrollView == nil) {
        _containerScrollView = [[UIScrollView alloc] init];
        _containerScrollView.pagingEnabled = YES;
        _containerScrollView.scrollsToTop = NO;
        _containerScrollView.bounces = NO;
        _containerScrollView.showsHorizontalScrollIndicator = NO;
        _containerScrollView.showsVerticalScrollIndicator = NO;
        _containerScrollView.scrollEnabled = NO;
    }
    return _containerScrollView;
}

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = similarPink;
    
    [self setUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - setUI

- (void)setUI
{
    if (@available(iOS 11.0, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.containerScrollView];
    [self.containerScrollView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    __weak typeof(self) weakSelf = self;
    
    if (self.containerArray.count != 0) {
        
        [self.containerArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            PHAsset *tempAsset = obj;
            weakSelf.containerScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * (idx + 1), SCREEN_WIDTH);
            QTClipImageContainerView *tempContainerView = [[QTClipImageContainerView alloc] init];

            [weakSelf.containerScrollView addSubview:tempContainerView];
            [tempContainerView makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.offset(SCREEN_WIDTH);
                make.centerY.offset(0);
                make.left.offset(idx * SCREEN_WIDTH);
            }];
            tempContainerView.clipAsset = tempAsset;
        }];
    }
}

@end
