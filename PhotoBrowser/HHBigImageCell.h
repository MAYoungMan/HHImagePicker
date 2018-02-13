//
//  HHBigImageCell.h
//  多选相册照片
//
//  Created by Sherlock on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;

@interface HHBigImageCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy)   void (^singleTapCallBack)();

@end
