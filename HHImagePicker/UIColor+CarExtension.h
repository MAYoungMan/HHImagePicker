//
//  UIColor+CarExtension.h
//  多选相册照片
//
//  Created by Sherlock on 18/8/20.
//  Copyright © 2018年 daHuiGe. All rights reserved.
//

#import <UIKit/UIKit.h>

/* 颜色值 */

//设置相册的主题色
extern const unsigned int COLOR_MAIN_THEME;       

@interface UIColor (CarExtension)

+ (UIColor *) colorWithHexString:(NSString *)stringToConvert;

+ (id) colorWithHex:(unsigned int)hex;

+ (id) colorWithHex:(unsigned int)hex alpha:(CGFloat)alpha;

+ (id) randomColor;

@end
