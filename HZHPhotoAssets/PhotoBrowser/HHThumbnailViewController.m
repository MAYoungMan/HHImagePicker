//
//  HHThumbnailViewController.m
//  多选相册照片
//
//  Created by Sherlock on 15/11/30.
//  Copyright © 2015年 long. All rights reserved.
//

#import "HHThumbnailViewController.h"
#import <Photos/Photos.h>
#import "HHDefine.h"
#import "HHCollectionCell.h"
#import "HHPhotoTool.h"
#import "HHSelectPhotoModel.h"
#import "HHShowBigImgViewController.h"
#import "HHPhotoBrowser.h"
#import "ToastUtils.h"

@interface AddCameraCell : UICollectionViewCell

@end

@implementation AddCameraCell

@end

@interface HHThumbnailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray<PHAsset *> *_arrayDataSources;
    
    BOOL _isLayoutOK;
}
@end

@implementation HHThumbnailViewController

static NSString * const cameraId = @"cameraCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"HHThumbnailViewController init");
    
    _arrayDataSources = [NSMutableArray array];
    
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 3.0f;
    
    self.doneNumber.layer.masksToBounds = YES;
    self.doneNumber.layer.cornerRadius = 10.0f;
    [self.btnDone setTitle:[NSString stringWithFormat:@"%@", GetLocalLanguageTextValue(HHPhotoBrowserDoneText)] forState:UIControlStateNormal];
    
    [self.btnPreView setTitle:[NSBundle hhLocalizedStringForKey:HHPhotoBrowserPreviewText] forState:UIControlStateNormal];
    [self.btnOriginalPhoto setTitle:[NSBundle hhLocalizedStringForKey:HHPhotoBrowserOriginalText] forState:UIControlStateNormal];
    [self.btnDone setTitle:[NSBundle hhLocalizedStringForKey:HHPhotoBrowserDoneText] forState:UIControlStateNormal];
    
    [self resetBottomBtnsStatus];
    [self getOriginalImageBytes];
    [self initNavBtn];
    [self initCollectionView];
    [self getAssetInAssetCollection];
}

-(void)dealloc{

    NSLog(@"HHThumbnailViewController dealloc");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isLayoutOK = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!_isLayoutOK) {
        if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
            [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height-self.collectionView.frame.size.height)];
        }
    }
}

- (void)resetBottomBtnsStatus
{
    if (self.arraySelectPhotos.count > 0) {
        self.btnOriginalPhoto.enabled = YES;
        self.btnPreView.enabled = YES;
        self.btnDone.enabled = YES;
        //[self.btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(HHPhotoBrowserDoneText), self.arraySelectPhotos.count] forState:UIControlStateNormal];
        [self.btnOriginalPhoto setTitleColor:[UIColor colorWithRed:35/255.0 green:209/255.0 blue:227/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.btnPreView setTitleColor:[UIColor colorWithRed:35/255.0 green:209/255.0 blue:227/255.0 alpha:1.0] forState:UIControlStateNormal];
        //self.btnDone.backgroundColor = kRGB(80, 180, 234);
        //[self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnDone setTitleColor:[UIColor colorWithRed:35/255.0 green:209/255.0 blue:227/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.doneNumber setTitle:[NSString stringWithFormat:@"%ld",self.arraySelectPhotos.count] forState:UIControlStateNormal];
        self.doneNumber.enabled = YES;
        [self.doneNumber setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:35/255.0 green:209/255.0 blue:227/255.0 alpha:1.0]] forState:UIControlStateNormal];
    } else {
        self.btnOriginalPhoto.enabled = NO;
        self.btnPreView.enabled = NO;
        self.btnDone.enabled = NO;
        //[self.btnDone setTitle:GetLocalLanguageTextValue(HHPhotoBrowserDoneText) forState:UIControlStateDisabled];
        [self.btnOriginalPhoto setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
        [self.btnPreView setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
        //self.btnDone.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        //[self.btnDone setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [self.btnDone setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
        self.doneNumber.enabled = NO;
        [self.doneNumber setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((kViewWidth-9)/3, (kViewWidth-9)/3);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HHCollectionCell" bundle:kHHPhotoBrowserBundle] forCellWithReuseIdentifier:@"HHCollectionCell"];
    
    [self.collectionView registerClass:[AddCameraCell class] forCellWithReuseIdentifier:cameraId];
    
}

- (void)getAssetInAssetCollection
{
    [_arrayDataSources addObjectsFromArray:[[HHPhotoTool sharePhotoTool] getAssetsInAssetCollection:self.assetCollection ascending:YES]];
}

- (void)initNavBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(HHPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(HHPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    //相册列表
    UIImage *navBackImg = [UIImage imageNamed:@"navBackBtn.png"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(navLeftBtn_Click)];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIView alloc]init] ];
}

#pragma mark - UIButton Action
- (void)cell_btn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        ShowToastLong(GetLocalLanguageTextValue(HHPhotoBrowserMaxSelectCountText), self.maxSelectCount);
        return;
    }
    
    PHAsset *asset = _arrayDataSources[btn.tag];

    if (!btn.selected) {
        //添加图片到选中数组
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        if (![[HHPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(HHPhotoBrowseriCloudPhotoText));
            return;
        }
        HHSelectPhotoModel *model = [[HHSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    } else {
        for (HHSelectPhotoModel *model in _arraySelectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                [_arraySelectPhotos removeObject:model];
                break;
            }
        }
    }
    
    btn.selected = !btn.selected;
    [self resetBottomBtnsStatus];
    [self getOriginalImageBytes];
}

- (IBAction)btnPreview_Click:(id)sender
{
    NSMutableArray<PHAsset *> *arrSel = [NSMutableArray array];
    for (HHSelectPhotoModel *model in self.arraySelectPhotos) {
        [arrSel addObject:model.asset];
    }
    [self pushShowBigImgVCWithDataArray:arrSel selectIndex:arrSel.count-1];
}

- (IBAction)btnOriginalPhoto_Click:(id)sender
{
    self.isSelectOriginalPhoto = !self.btnOriginalPhoto.selected;
    [self getOriginalImageBytes];
}

- (IBAction)btnDone_Click:(id)sender
{
    if (self.DoneBlock) {
        self.DoneBlock(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
}

- (void)navLeftBtn_Click
{
    self.sender.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    self.sender.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightBtn_Click
{
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    /*
    //新增相机
    return _arrayDataSources.count + 1;
    */
    return _arrayDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*
     //新增相机
    if(indexPath.row == 0){
        
        AddCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cameraId forIndexPath:indexPath];
        if (cell.backgroundView == nil) {//防止多次创建
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.clipsToBounds=YES;
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.image = [UIImage imageNamed:@"xj"];
            cell.backgroundView = imageView;
        }
        
        return cell;
    }else{
     
    */
    
        HHCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HHCollectionCell" forIndexPath:indexPath];
        
        cell.btnSelect.selected = NO;
    /*
    //新增相机
        PHAsset *asset = _arrayDataSources[indexPath.row-1];
    */
    PHAsset *asset = _arrayDataSources[indexPath.row];
    
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.clipsToBounds = YES;
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize cellSize = cell.frame.size;
        CGFloat sizeEdge = cellSize.width *scale;
        CGSize size = CGSizeMake(sizeEdge, sizeEdge);
        
        weakify(self);
        [[HHPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
            strongify(weakSelf);
            cell.imageView.image = image;
            for (HHSelectPhotoModel *model in strongSelf.arraySelectPhotos) {
                if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                    cell.btnSelect.selected = YES;
                    break;
                }
            }
        }];
    /*
     //新增相机
        cell.btnSelect.tag = indexPath.row-1;
     */
        cell.btnSelect.tag = indexPath.row;
        [cell.btnSelect addTarget:self action:@selector(cell_btn_Click:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    /*
    }
     */
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%ld",indexPath.row);
    
    /*
    //新增相机
    if(indexPath.row == 0){
        //delete
        //相册中添加相机
        if (self.CancelBlock) {
            self.CancelBlock();
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
        NSNotification * not = [NSNotification notificationWithName:@"HHThumbnailTakePhotoNotification" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotification:not];

    }else{
        [self pushShowBigImgVCWithDataArray:_arrayDataSources selectIndex:indexPath.row-1];
    }
    */
    
    [self pushShowBigImgVCWithDataArray:_arrayDataSources selectIndex:indexPath.row];
    
}

- (void)pushShowBigImgVCWithDataArray:(NSArray<PHAsset *> *)dataArray selectIndex:(NSInteger)selectIndex
{
    HHShowBigImgViewController *svc = [[HHShowBigImgViewController alloc] init];
    svc.assets         = dataArray;
    svc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    svc.selectIndex    = selectIndex;
    svc.maxSelectCount = _maxSelectCount;
    svc.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    svc.isPresent = NO;
    svc.shouldReverseAssets = NO;
    
    weakify(self);
    [svc setOnSelectedPhotos:^(NSArray<HHSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        strongify(weakSelf);
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf.arraySelectPhotos removeAllObjects];
        [strongSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [strongSelf.collectionView reloadData];
        [strongSelf getOriginalImageBytes];
        [strongSelf resetBottomBtnsStatus];
    }];
    [svc setBtnDoneBlock:^(NSArray<HHSelectPhotoModel *> *selectedPhotos, BOOL isSelectOriginalPhoto) {
        strongify(weakSelf);
        strongSelf.isSelectOriginalPhoto = isSelectOriginalPhoto;
        [strongSelf.arraySelectPhotos removeAllObjects];
        [strongSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [strongSelf btnDone_Click:nil];
    }];
    
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)getOriginalImageBytes
{
    weakify(self);
    if (self.isSelectOriginalPhoto && self.arraySelectPhotos.count > 0) {
        [[HHPhotoTool sharePhotoTool] getPhotosBytesWithArray:self.arraySelectPhotos completion:^(NSString *photosBytes) {
            strongify(weakSelf);
            strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
        }];
        self.btnOriginalPhoto.selected = self.isSelectOriginalPhoto;
    } else {
        self.btnOriginalPhoto.selected = NO;
        self.labPhotosBytes.text = nil;
    }
}

@end
