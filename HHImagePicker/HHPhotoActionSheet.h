//
//  HHPhotoActionSheet.h
//  多选相册照片
//
//  Created by Sherlock on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HHSelectPhotoModel;

@interface HHPhotoActionSheet : UIView

@property (nonatomic, weak) UIViewController *sender;

/** 最大选择数 default is 9 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/** 预览图最大显示数 default is 25 */
@property (nonatomic, assign) NSInteger maxPreviewCount;

- (instancetype)initWithframe:(CGRect)rect SuperView:(UIView *)superView;

/**
 * @brief 显示多选照片视图，带预览效果
 * @param sender
 *              调用该控件的视图控制器
 * @param lastSelectPhotoModels
 *              已选择的PHAsset，再次调用"showWithSender:animate:lastSelectPhotoModels:completion:"方法之前，可以把上次回调中selectPhotoModels赋值给该属性，便可实现记录上次选择照片的功能，若不需要记录上次选择照片的功能，则该值传nil即可
 * @param completion
 *              完成回调
 */
- (void)showPreviewPhotoWithSender:(UIViewController *)sender
   lastSelectPhotoModels:(NSArray<HHSelectPhotoModel *> * _Nullable)lastSelectPhotoModels
              completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<HHSelectPhotoModel *> *selectPhotoModels))completion;

/**
 * @brief 显示多选照片视图，直接进入相册选择界面
 * @param sender
 *              调用该控件的视图控制器
 * @param lastSelectPhotoModels
 *              已选择的PHAsset，再次调用"showWithSender:animate:lastSelectPhotoModels:completion:"方法之前，可以把上次回调中selectPhotoModels赋值给该属性，便可实现记录上次选择照片的功能，若不需要记录上次选择照片的功能，则该值传nil即可
 * @param completion
 *              完成回调
 */
- (void)showPhotoLibraryWithSender:(UIViewController *)sender
             lastSelectPhotoModels:(NSArray<HHSelectPhotoModel *> * _Nullable)lastSelectPhotoModels
                        completion:(void (^)(NSArray<UIImage *> *selectPhotos, NSArray<HHSelectPhotoModel *> *selectPhotoModels))completion;

NS_ASSUME_NONNULL_END

@end



@interface CustomerNavgationController : UINavigationController

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

@end
