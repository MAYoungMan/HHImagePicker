//
//  HHPhotoBrowser.h
//  多选相册照片
//
//  Created by Sherlock on 15/11/27.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHSelectPhotoModel;

@interface HHPhotoBrowser : UITableViewController

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectCount;
//是否选择了原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
//当前已经选择的图片
@property (nonatomic, strong) NSMutableArray<HHSelectPhotoModel *> *arraySelectPhotos;

//选则完成后回调
@property (nonatomic, copy) void (^DoneBlock)(NSArray<HHSelectPhotoModel *> *selPhotoModels, BOOL isSelectOriginalPhoto);
//取消选择后回调
@property (nonatomic, copy) void (^CancelBlock)(void);

@end
