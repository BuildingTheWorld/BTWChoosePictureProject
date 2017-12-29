//
//  QTClipImageContainerView.h
//  QingTengShe
//
//  Created by QT on 2017/11/29.
//

#import <UIKit/UIKit.h>

#import <Photos/Photos.h>

typedef void(^QTiCloudDownBlock)(void);

@interface QTClipImageContainerView : UIView

@property (nonatomic, strong) PHAsset *clipAsset;

@property (nonatomic, strong) UIScrollView *clipScrollView;

@property (nonatomic, strong) UIImageView *clipImageView;

@property (nonatomic, strong) QTiCloudDownBlock iCloudDownBlock;

@end
