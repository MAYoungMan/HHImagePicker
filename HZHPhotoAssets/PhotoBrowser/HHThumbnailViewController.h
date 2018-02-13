//
//  HHThumbnailViewController.h
//  多选相册照片
//
//  Created by Sherlock on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAssetCollection;
@class HHSelectPhotoModel;
@class HHPhotoBrowser;

@interface HHThumbnailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//相册属性
@property (nonatomic, strong) PHAssetCollection *assetCollection;

//当前已经选择的图片
@property (nonatomic, strong) NSMutableArray<HHSelectPhotoModel *> *arraySelectPhotos;

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectCount;
//是否选择了原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (weak, nonatomic) IBOutlet UIButton *btnPreView;
@property (weak, nonatomic) IBOutlet UIButton *btnOriginalPhoto;
@property (weak, nonatomic) IBOutlet UILabel *labPhotosBytes;

@property (weak, nonatomic) IBOutlet UIButton *doneNumber;

@property (weak, nonatomic) IBOutlet UIButton *btnDone;

//用于回调上级列表，把已选择的图片传回去
@property (nonatomic, weak) HHPhotoBrowser *sender;

//选则完成后回调
@property (nonatomic, copy) void (^DoneBlock)(NSArray<HHSelectPhotoModel *> *selPhotoModels, BOOL isSelectOriginalPhoto);
//取消选择后回调
@property (nonatomic, copy) void (^CancelBlock)(void);

@end
