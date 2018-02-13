//
//  HHPhotoBrowserCell.h
//  多选相册照片
//
//  Created by Sherlock on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHPhotoBrowserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labCount;

@end
