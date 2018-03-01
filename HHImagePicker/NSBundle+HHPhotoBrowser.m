//
//  NSBundle+HHPhotoBrowser.m
//  HHPhotoBrowser
//
//  Created by Sherlock on 16/10/20.
//  Copyright © 2016年 long. All rights reserved.
//

#import "NSBundle+HHPhotoBrowser.h"
#import "HHPhotoActionSheet.h"

@implementation NSBundle (HHPhotoBrowser)

+ (instancetype)hhPhotoBrowserBundle
{
    static NSBundle *refreshBundle = nil;
    if (refreshBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        refreshBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[HHPhotoActionSheet class]] pathForResource:@"HHPhotoBrowser" ofType:@"bundle"]];
    }
    return refreshBundle;
}

+ (NSString *)hhLocalizedStringForKey:(NSString *)key
{
    return [self hhLocalizedStringForKey:key value:nil];
}

+ (NSString *)hhLocalizedStringForKey:(NSString *)key value:(NSString *)value
{
    NSBundle *bundle = nil;
    if (bundle == nil) {
        
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *currentLanguage = [languages objectAtIndex:0];

        NSString *language = currentLanguage;
        
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        } else
        {
            language = @"zh-Hans"; // 简体中文
        }
        
        // 从MJRefresh.bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[NSBundle hhPhotoBrowserBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

@end
