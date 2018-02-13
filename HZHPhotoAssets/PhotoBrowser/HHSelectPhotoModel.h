//
//  HHSelectPhotoModel.h
//  多选相册照片
//
//  Created by Sherlock on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HHSelectPhotoModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *localIdentifier;

@end
