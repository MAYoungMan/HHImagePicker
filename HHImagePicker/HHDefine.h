//
//  HHDefine.h
//  多选相册照片
//
//  Created by Sherlock on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#ifndef HHDefine_h
#define HHDefine_h

#import "HHProgressHUD.h"
#import "NSBundle+HHPhotoBrowser.h"

#define HHPhotoBrowserCameraText @"HHPhotoBrowserCameraText"
#define HHPhotoBrowserAblumText @"HHPhotoBrowserAblumText"
#define HHPhotoBrowserCancelText @"HHPhotoBrowserCancelText"
#define HHPhotoBrowserOriginalText @"HHPhotoBrowserOriginalText"
#define HHPhotoBrowserDoneText @"HHPhotoBrowserDoneText"
#define HHPhotoBrowserOKText @"HHPhotoBrowserOKText"
#define HHPhotoBrowserPhotoText @"HHPhotoBrowserPhotoText"
#define HHPhotoBrowserPreviewText @"HHPhotoBrowserPreviewText"
#define HHPhotoBrowserLoadingText @"HHPhotoBrowserLoadingText"
#define HHPhotoBrowserHandleText @"HHPhotoBrowserHandleText"
#define HHPhotoBrowserSaveImageErrorText @"HHPhotoBrowserSaveImageErrorText"
#define HHPhotoBrowserMaxSelectCountText @"HHPhotoBrowserMaxSelectCountText"
#define HHPhotoBrowserNoCameraAuthorityText @"HHPhotoBrowserNoCameraAuthorityText"
#define HHPhotoBrowserNoAblumAuthorityText @"HHPhotoBrowserNoAblumAuthorityText"
#define HHPhotoBrowseriCloudPhotoText @"HHPhotoBrowseriCloudPhotoText"

#define HHPhotoBrowserPhotoAccessText @"HHPhotoBrowserPhotoAccessText"
#define HHPhotoBrowserSettingText @"HHPhotoBrowserSettingText"
#define HHPhotoBrowserRefusedText @"HHPhotoBrowserRefusedText"

#define HHPhotoBrowserCameraRoll @"HHPhotoBrowserCameraRoll"
#define HHPhotoBrowserPanoramas @"HHPhotoBrowserPanoramas"
#define HHPhotoBrowserVideos @"HHPhotoBrowserVideos"
#define HHPhotoBrowserFavorites @"HHPhotoBrowserFavorites"
#define HHPhotoBrowserTimelapses @"HHPhotoBrowserTimelapses"
#define HHPhotoBrowserRecentlyAdded @"HHPhotoBrowserRecentlyAdded"
#define HHPhotoBrowserBursts @"HHPhotoBrowserBursts"
#define HHPhotoBrowserSlomoVideos @"HHPhotoBrowserSlomoVideos"
#define HHPhotoBrowserSelfPortraits @"HHPhotoBrowserSelfPortraits"
#define HHPhotoBrowserScreenshots @"HHPhotoBrowserScreenshots"
#define HHPhotoBrowserDepthEffect @"HHPhotoBrowserDepthEffect"
#define HHPhotoBrowserLivePhotos @"HHPhotoBrowserLivePhotos"
#define HHPhotoBrowserAnimated @"HHPhotoBrowserAnimated"

#define kRGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define weakify(var)   __weak typeof(var) weakSelf = var
#define strongify(var) __strong typeof(var) strongSelf = var

#define kHHPhotoBrowserBundle [NSBundle bundleForClass:[self class]]

// 图片路径
//#define kHHPhotoBrowserSrcName(file) [@"HHPhotoBrowser.bundle" stringByAppendingPathComponent:file]
//#define kHHPhotoBrowserFrameworkSrcName(file) [@"Frameworks/HHPhotoBrowser.framework/HHPhotoBrowser.bundle" stringByAppendingPathComponent:file]

#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
//如果项目中设置了导航条为不透明，即[UINavigationBar appearance].translucent=NO，那么这里的kViewHeight需要-64
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height

////////HHPhotoActionSheet
#define kBaseViewHeight 300

////////HHShowBigImgViewController
#define kItemMargin 30

///////HHBigImageCell 不建议设置太大，太大的话会导致图片加载过慢
#define kMaxImageWidth 500

#define longer ((kViewWidth > kViewHeight) ? kViewWidth : kViewHeight)
#define shorter ((kViewWidth > kViewHeight) ? kViewHeight : kViewWidth)

#define isIPhoneX ((longer == 812) ? YES : NO)
#define kNavBarHeight (isIPhoneX ? 88 : 64)
#define kHomeIndicator (isIPhoneX ? 34 : 0)
#define statusBarOffset 24
#define statusBarHeight (isIPhoneX ? 44 : 20)
#define toolBarOffset 34

static inline void SetViewWidth (UIView *view, CGFloat width) {
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

static inline CGFloat GetViewWidth (UIView *view) {
    return view.frame.size.width;
}

static inline void SetViewHeight (UIView *view, CGFloat height) {
    CGRect frame = view.frame;
    frame.size.height = height;
    view.frame = frame;
}

static inline CGFloat GetViewHeight (UIView *view) {
    return view.frame.size.height;
}

static inline NSString *  GetLocalLanguageTextValue (NSString *key) {
    return [NSBundle hhLocalizedStringForKey:key];
}

static inline CGFloat GetMatchValue (NSString *text, CGFloat fontSize, BOOL isHeightFixed, CGFloat fixedValue) {
    CGSize size;
    if (isHeightFixed) {
        size = CGSizeMake(MAXFLOAT, fixedValue);
    } else {
        size = CGSizeMake(fixedValue, MAXFLOAT);
    }
    
    CGSize resultSize;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        //返回计算出的size
        resultSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
    }
    if (isHeightFixed) {
        return resultSize.width;
    } else {
        return resultSize.height;
    }
}

static inline CABasicAnimation * GetPositionAnimation (id fromValue, id toValue, CFTimeInterval duration, NSString *keyPath) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue   = toValue;
    animation.duration = duration;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    //以下两个设置，保证了动画结束后，layer不会回到初始位置
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

static inline CAKeyframeAnimation * GetBtnStatusChangedAnimation() {
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    return animate;
}

#endif /* HHDefine_h */
