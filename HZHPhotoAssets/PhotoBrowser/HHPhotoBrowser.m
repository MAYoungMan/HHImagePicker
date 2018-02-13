//
//  HHPhotoBrowser.m
//  多选相册照片
//
//  Created by Sherlock on 15/11/27.
//  Copyright © 2015年 long. All rights reserved.
//

#import "HHPhotoBrowser.h"
#import "HHPhotoBrowserCell.h"
#import "HHPhotoTool.h"
#import "HHThumbnailViewController.h"
#import "HHDefine.h"

@interface HHPhotoBrowser ()
{
    NSMutableArray<HHPhotoAblumList *> *_arrayDataSources;
}
@end

@implementation HHPhotoBrowser

-(instancetype)init{

    if (self = [super init]) {
        NSLog(@"HHPhotoBrowser init");
    }
    return  self;
}
-(void)dealloc{

    NSLog(@"HHPhotoBrowser dealloc");
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.title = GetLocalLanguageTextValue(HHPhotoBrowserPhotoText);
    
    _arrayDataSources = [NSMutableArray array];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self initNavBtn];
    [self loadAblums];
    [self pushAllPhotoSoon];
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
    self.navigationItem.hidesBackButton = YES;
}

- (void)loadAblums
{
    [_arrayDataSources addObjectsFromArray:[[HHPhotoTool sharePhotoTool] getPhotoAblumList]];
}

#pragma mark - 直接push到所有照片界面
- (void)pushAllPhotoSoon
{
    NSInteger i = 0;
    for (HHPhotoAblumList *ablum in _arrayDataSources) {
        if (ablum.assetCollection.assetCollectionSubtype == 209) {
            i = [_arrayDataSources indexOfObject:ablum];
            break;
        }
    }
    [self pushThumbnailVCWithIndex:i animated:NO];
}

- (void)navRightBtn_Click
{
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrayDataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHPhotoBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHPhotoBrowserCell"];
    
    if (!cell) {
        cell = [[kHHPhotoBrowserBundle loadNibNamed:@"HHPhotoBrowserCell" owner:self options:nil] lastObject];
    }
    HHPhotoAblumList *ablumList= _arrayDataSources[indexPath.row];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat sizeEdge = 65 * scale;
    CGSize size = CGSizeMake(sizeEdge, sizeEdge);
    
    [[HHPhotoTool sharePhotoTool] requestImageForAsset:ablumList.headImageAsset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        cell.headImageView.image = image;
    }];
    cell.labTitle.text = ablumList.title;
    cell.labCount.text = [NSString stringWithFormat:@"(%ld)", ablumList.count];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushThumbnailVCWithIndex:indexPath.row animated:YES];
}

- (void)pushThumbnailVCWithIndex:(NSInteger)index animated:(BOOL)animated
{
    HHPhotoAblumList *ablum = _arrayDataSources[index];
    
    HHThumbnailViewController *tvc = [[HHThumbnailViewController alloc] initWithNibName:@"HHThumbnailViewController" bundle:kHHPhotoBrowserBundle];
    tvc.title = ablum.title;
    tvc.maxSelectCount = self.maxSelectCount;
    tvc.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    tvc.assetCollection = ablum.assetCollection;
    tvc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    tvc.sender = self;
    tvc.DoneBlock = self.DoneBlock;
    tvc.CancelBlock = self.CancelBlock;
    [self.navigationController pushViewController:tvc animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
