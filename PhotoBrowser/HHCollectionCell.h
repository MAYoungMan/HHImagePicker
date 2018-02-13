//
//  HHCollectionCell.h
//  多选相册照片
//
//  Created by Sherlock on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;

@end
