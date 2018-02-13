//
//  NSBundle+HHPhotoBrowser.h
//  HHPhotoBrowser
//
//  Created by Sherlock on 16/10/20.
//  Copyright © 2016年 long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (HHPhotoBrowser)

+ (instancetype)hhPhotoBrowserBundle;

+ (NSString *)hhLocalizedStringForKey:(NSString *)key;

+ (NSString *)hhLocalizedStringForKey:(NSString *)key value:(NSString *)value;

@end
