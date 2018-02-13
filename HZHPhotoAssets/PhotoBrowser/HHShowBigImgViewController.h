//
//  HHShowBigImgViewController.h
//  多选相册照片
//
//  Created by Sherlock on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class HHSelectPhotoModel;

@interface HHShowBigImgViewController : UIViewController

@property (nonatomic, strong) NSArray<PHAsset *> *assets;

@property (nonatomic, strong) NSMutableArray<HHSelectPhotoModel *> *arraySelectPhotos;

@property (nonatomic, assign) NSInteger selectIndex; //选中的图片下标

@property (nonatomic, assign) NSInteger maxSelectCount; //最大选择照片数

@property (nonatomic, assign) BOOL isSelectOriginalPhoto; //是否选择了原图

@property (nonatomic, assign) BOOL isPresent; //该界面显示方式，预览界面查看大图进来是present，从相册小图进来是push

@property (nonatomic, assign) BOOL shouldReverseAssets; //是否需要对接收到的图片数组进行逆序排列

@property (nonatomic, copy) void (^onSelectedPhotos)(NSArray<HHSelectPhotoModel *> *, BOOL isSelectOriginalPhoto); //点击返回按钮的回调

@property (nonatomic, copy) void (^btnDoneBlock)(NSArray<HHSelectPhotoModel *> *, BOOL isSelectOriginalPhoto); //点击确定按钮回调

@end
