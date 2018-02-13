//
//  HHPhotoActionSheet.m
//  多选相册照片
//
//  Created by Sherlock on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import "HHPhotoActionSheet.h"
#import <Photos/Photos.h>
#import "HHCollectionCell.h"
#import "HHShowBigImgViewController.h"
#import "HHDefine.h"
#import "HHSelectPhotoModel.h"
#import "HHPhotoTool.h"
#import "HHNoAuthorityViewController.h"
#import "HHPhotoBrowser.h"
#import "ToastUtils.h"
#import <objc/runtime.h>

typedef void (^handler)(NSArray<UIImage *> *selectPhotos, NSArray<HHSelectPhotoModel *> *selectPhotoModels);

@interface HHPhotoActionSheet () <UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnAblum;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) BOOL preview;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *arrayDataSources;
@property (nonatomic, strong) NSMutableArray<HHSelectPhotoModel *> *arraySelectPhotos;
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, copy)   handler handler;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, assign) BOOL senderTabBarIsShow;

@end

@implementation HHPhotoActionSheet

- (instancetype)initWithframe:(CGRect)rect SuperView:(UIView *)superView
{
    self = [[kHHPhotoBrowserBundle loadNibNamed:@"HHPhotoActionSheet" owner:self options:nil] lastObject];
    if (self) {
        NSLog(@"HHPhotoActionSheet init");
                
        self.frame = rect;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        self.collectionView.collectionViewLayout = layout;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView registerNib:[UINib nibWithNibName:@"HHCollectionCell" bundle:kHHPhotoBrowserBundle] forCellWithReuseIdentifier:@"HHCollectionCell"];
        
        self.maxSelectCount = 9;
        self.maxPreviewCount = 25;
        self.arrayDataSources  = [NSMutableArray array];
        self.arraySelectPhotos = [NSMutableArray array];
        
        if (![self judgeIsHavePhotoAblumAuthority]) {
            //注册实施监听相册变化
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        }
        
        [superView addSubview:self];
        
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"HHPhotoActionSheet dealloc");
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.btnCamera setTitle:GetLocalLanguageTextValue(HHPhotoBrowserCameraText) forState:UIControlStateNormal];
    [self.btnAblum setTitle:GetLocalLanguageTextValue(HHPhotoBrowserAblumText) forState:UIControlStateNormal];
    [self.btnCancel setTitle:GetLocalLanguageTextValue(HHPhotoBrowserCancelText) forState:UIControlStateNormal];
    [self resetSubViewState];
}

//相册变化回调
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (self.preview) {
            [self loadPhotoFromAlbum];
        } else {
            [self btnPhotoLibrary_Click:nil];
        }
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    });
}

- (void)showPreviewPhotoWithSender:(UIViewController *)sender lastSelectPhotoModels:(NSArray<HHSelectPhotoModel *> *)lastSelectPhotoModels completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<HHSelectPhotoModel *> * _Nonnull))completion
{
    [self showPreview:YES sender:sender lastSelectPhotoModels:lastSelectPhotoModels completion:completion];
}

- (void)showPhotoLibraryWithSender:(UIViewController *)sender lastSelectPhotoModels:(NSArray<HHSelectPhotoModel *> *)lastSelectPhotoModels completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<HHSelectPhotoModel *> * _Nonnull))completion
{
    [self showPreview:NO sender:sender lastSelectPhotoModels:lastSelectPhotoModels completion:completion];
}

- (void)showPreview:(BOOL)preview sender:(UIViewController *)sender lastSelectPhotoModels:(NSArray<HHSelectPhotoModel *> *)lastSelectPhotoModels completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray<HHSelectPhotoModel *> * _Nonnull))completion
{
    self.handler = completion;
    self.preview = preview;
    self.sender  = sender;
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [self.arraySelectPhotos removeAllObjects];
    [self.arraySelectPhotos addObjectsFromArray:lastSelectPhotoModels];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    [self addAssociatedOnSender];
    if (preview) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self loadPhotoFromAlbum];
        } else if (status == PHAuthorizationStatusRestricted ||
                   status == PHAuthorizationStatusDenied) {
            [self showNoAuthorityVC];
        }
    } else {
        if (status == PHAuthorizationStatusAuthorized) {
            [self btnPhotoLibrary_Click:nil];
        } else if (status == PHAuthorizationStatusRestricted ||
                   status == PHAuthorizationStatusDenied) {
            [self showNoAuthorityVC];
        }
    }
}

static char RelatedKey;
- (void)addAssociatedOnSender
{
    BOOL selfInstanceIsClassVar = NO;
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList(self.sender.class, &count);
    for (int i = 0; i < count; i++) {
        Ivar var = vars[i];
        const char * type = ivar_getTypeEncoding(var);
        NSString *className = [NSString stringWithUTF8String:type];
        if ([className isEqualToString:[NSString stringWithFormat:@"@\"%@\"", NSStringFromClass(self.class)]]) {
            selfInstanceIsClassVar = YES;
        }
    }
    if (!selfInstanceIsClassVar) {
        objc_setAssociatedObject(self.sender, &RelatedKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - 判断软件是否有相册、相机访问权限
- (BOOL)judgeIsHavePhotoAblumAuthority
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

- (BOOL)judgeIsHaveCameraAuthority
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(HHPhotoBrowserOKText) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self.sender presentViewController:alert animated:YES completion:nil];
}

- (void)loadPhotoFromAlbum
{
    [self.arrayDataSources removeAllObjects];
    [self.arrayDataSources addObjectsFromArray:[[HHPhotoTool sharePhotoTool] getAllAssetInPhotoAblumWithAscending:NO]];
    
    [self.collectionView reloadData];
}

#pragma mark - 显示隐藏视图及相关动画
- (void)resetSubViewState
{
    [self changeBtnCameraTitle];
    [self.collectionView setContentOffset:CGPointZero];
}

#pragma mark - UIButton Action
- (IBAction)btnCamera_Click:(id)sender
{
    if (self.arraySelectPhotos.count > 0) {
        [self requestSelPhotos:nil];
    } else {
        if (![self judgeIsHaveCameraAuthority]) {
            NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(HHPhotoBrowserNoCameraAuthorityText), [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]];
            [self showAlertWithTitle:nil message:message];
            return;
        }
        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.videoQuality = UIImagePickerControllerQualityTypeLow;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.sender presentViewController:picker animated:YES completion:nil];
        }
    }
}

- (IBAction)btnPhotoLibrary_Click:(id)sender
{
    if (![self judgeIsHavePhotoAblumAuthority]) {
        [self showNoAuthorityVC];
    } else {
        
        HHPhotoBrowser *photoBrowser = [[HHPhotoBrowser alloc] initWithStyle:UITableViewStylePlain];
        photoBrowser.maxSelectCount = self.maxSelectCount;
        photoBrowser.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
        
        weakify(self);
        __weak typeof(photoBrowser) weakPB = photoBrowser;
        [photoBrowser setDoneBlock:^(NSArray<HHSelectPhotoModel *> *selPhotoModels, BOOL isSelectOriginalPhoto) {
            strongify(weakSelf);
            __strong typeof(weakPB) strongPB = weakPB;
            strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
            [strongSelf.arraySelectPhotos removeAllObjects];
            [strongSelf.arraySelectPhotos addObjectsFromArray:selPhotoModels];
            [strongSelf requestSelPhotos:strongPB];
        }];
        
        [photoBrowser setCancelBlock:^{
            self.handler = nil;
        }];
        
        [self presentVC:photoBrowser];
    }
}

- (IBAction)btnCancel_Click:(id)sender
{
    [self.arraySelectPhotos removeAllObjects];
}

- (void)cell_btn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        ShowToastLong(GetLocalLanguageTextValue(HHPhotoBrowserMaxSelectCountText), self.maxSelectCount);
        return;
    }
    
    PHAsset *asset = self.arrayDataSources[btn.tag];
    
    if (!btn.selected) {
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        if (![[HHPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(HHPhotoBrowseriCloudPhotoText));
            return;
        }
        HHSelectPhotoModel *model = [[HHSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [self.arraySelectPhotos addObject:model];
    } else {
        for (HHSelectPhotoModel *model in self.arraySelectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                [self.arraySelectPhotos removeObject:model];
                break;
            }
        }
    }
    
    btn.selected = !btn.selected;
    [self changeBtnCameraTitle];
}

- (void)changeBtnCameraTitle
{
    if (self.arraySelectPhotos.count > 0) {
        [self.btnCamera setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(HHPhotoBrowserDoneText), self.arraySelectPhotos.count] forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:[UIColor colorWithRed:35/255.0 green:209/255.0 blue:227/255.0 alpha:1.0] forState:UIControlStateNormal];
    } else {
        [self.btnCamera setTitle:GetLocalLanguageTextValue(HHPhotoBrowserCameraText) forState:UIControlStateNormal];
        [self.btnCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 请求所选择图片、回调
- (void)requestSelPhotos:(UIViewController *)vc
{
    HHProgressHUD *hud = [[HHProgressHUD alloc] init];
    [hud show];
    
    weakify(self);
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:self.arraySelectPhotos.count];
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        [photos addObject:@""];
    }
    
    CGFloat scale = self.isSelectOriginalPhoto?1:[UIScreen mainScreen].scale;
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        HHSelectPhotoModel *model = self.arraySelectPhotos[i];
        [[HHPhotoTool sharePhotoTool] requestImageForAsset:model.asset scale:scale resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            strongify(weakSelf);
            if (image) [photos replaceObjectAtIndex:i withObject:[self scaleImage:image]];
            //if (image) [photos replaceObjectAtIndex:i withObject:image];
            
            for (id obj in photos) {
                if ([obj isKindOfClass:[NSString class]]) return;
            }
            
            [hud hide];
            [strongSelf done:photos];
            [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

/**
 * @brief 这里对拿到的图片进行缩放，不然原图直接返回的话会造成内存暴涨
 */
- (UIImage *)scaleImage:(UIImage *)image
{
    CGSize size = CGSizeMake(image.size.width, image.size.height);
    CGFloat scaleWH = image.size.width / image.size.height;
    if (scaleWH >= 1280/720 && image.size.width>=1280) {
        size = CGSizeMake(1280, 1280*image.size.height/image.size.width);
    }
    if (scaleWH < 1280/720 && image.size.height>720) {
        size = CGSizeMake(720*image.size.width/image.size.height, 720);
    }
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)done:(NSArray<UIImage *> *)photos
{
    if (self.handler) {
        self.handler(photos, self.arraySelectPhotos.copy);
        self.handler = nil;
    }
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.maxPreviewCount>_arrayDataSources.count?_arrayDataSources.count:self.maxPreviewCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HHCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HHCollectionCell" forIndexPath:indexPath];

    cell.btnSelect.selected = NO;
    PHAsset *asset = _arrayDataSources[indexPath.row];
    weakify(self);
    [self getImageWithAsset:asset completion:^(UIImage *image, NSDictionary *info) {
        strongify(weakSelf);
        cell.imageView.image = image;
        for (HHSelectPhotoModel *model in strongSelf.arraySelectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                cell.btnSelect.selected = YES;
                break;
            }
        }
    }];

    cell.btnSelect.tag = indexPath.row;
    [cell.btnSelect addTarget:self action:@selector(cell_btn_Click:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
    
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = self.arrayDataSources[indexPath.row];
    return [self getSizeWithAsset:asset];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HHShowBigImgViewController *svc = [[HHShowBigImgViewController alloc] init];
    svc.assets         = _arrayDataSources;
    svc.arraySelectPhotos = [NSMutableArray arrayWithArray:_arraySelectPhotos];
    svc.selectIndex    = indexPath.row;
    svc.maxSelectCount = _maxSelectCount;
    svc.isPresent = YES;
    svc.shouldReverseAssets = YES;
    weakify(self);
    __weak typeof(svc) weakSvc  = svc;
    [svc setOnSelectedPhotos:^(NSArray<HHSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        strongify(weakSelf);
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf.arraySelectPhotos removeAllObjects];
        [strongSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [strongSelf changeBtnCameraTitle];
        [strongSelf.collectionView reloadData];
    }];
    [svc setBtnDoneBlock:^(NSArray<HHSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        strongify(weakSelf);
        __strong typeof(weakSvc) strongSvc = weakSvc;
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf.arraySelectPhotos removeAllObjects];
        [strongSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [strongSelf requestSelPhotos:strongSvc];
    }];
    [self presentVC:svc];
}

#pragma mark - 显示无权限视图
- (void)showNoAuthorityVC
{
    //无相册访问权限
    /*
    HHNoAuthorityViewController *nvc = [[HHNoAuthorityViewController alloc] initWithNibName:@"HHNoAuthorityViewController" bundle:kHHPhotoBrowserBundle];
    [self presentVC:nvc];
     */
    
    ShowToastPhotoPrompt(self);
    
}

- (void)presentVC:(UIViewController *)vc
{
    CustomerNavgationController *nav = [[CustomerNavgationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = YES;
    nav.previousStatusBarStyle = self.previousStatusBarStyle;
    
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    //[nav.navigationBar setBackgroundImage:[self imageWithColor:kRGB(19, 153, 231)] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setBackgroundImage:[self imageWithColor:kRGB(51, 51, 51)] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    
    [self.sender presentViewController:nav animated:YES completion:nil];
}

- (UIImage *)imageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        strongify(weakSelf);
        if (strongSelf.handler) {
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            HHProgressHUD *hud = [[HHProgressHUD alloc] init];
            [hud show];
            
            [[HHPhotoTool sharePhotoTool] saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (suc) {
                        HHSelectPhotoModel *model = [[HHSelectPhotoModel alloc] init];
                        model.asset = asset;
                        model.localIdentifier = asset.localIdentifier;
                        strongSelf.handler(@[[strongSelf scaleImage:image]], @[model]);
                    } else {
                        ShowToastLong(@"%@", GetLocalLanguageTextValue(HHPhotoBrowserSaveImageErrorText));
                    }
                    [hud hide];
                });
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - 获取图片及图片尺寸的相关方法
- (CGSize)getSizeWithAsset:(PHAsset *)asset
{
    CGFloat width  = (CGFloat)asset.pixelWidth;
    CGFloat height = (CGFloat)asset.pixelHeight;
    CGFloat scale = width/height;
    
    return CGSizeMake(self.collectionView.frame.size.height*scale, self.collectionView.frame.size.height);
}

- (void)getImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    CGSize cellSize = [self getSizeWithAsset:asset];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat sizeEdge = cellSize.width *scale;
    CGSize size = CGSizeMake(sizeEdge, sizeEdge);
    
    [[HHPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
}

@end


#pragma mark - 自定义导航控制器
@implementation CustomerNavgationController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.previousStatusBarStyle;
//    [self setNeedsStatusBarAppearanceUpdate];
}

//BOOL dismiss = NO;
//- (UIStatusBarStyle)previousStatusBarStyle
//{
//    if (!dismiss) {
//        return UIStatusBarStyleLightContent;
//    } else {
//        return self.previousStatusBarStyle;
//    }
//}

@end
