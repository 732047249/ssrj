//
//  SMMyGoodsController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMyGoodsController.h"
#import "SMSearchGoodsController.h"
#import "SMGoodsDetailController.h"
#import "SMCreateMatchController.h"
#import "AJPhotoPickerViewController.h"
#import "SMMyGoodsCell.h"
#import "SMAllGoodsSearchView.h"
#import "Masonry.h"
static NSString *const MyGoodsUrl = @"/b180/api/v1/goodsinfor/my_goods";
static NSString * const UploadImageUrl = @"/b180/api/v1/collocationupload/uploadimage";
@interface SMMyGoodsController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,AJPhotoPickerProtocol,SMAllGoodsSearchViewDelegate>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)SMAllGoodsSearchView * searchView;

@end

@implementation SMMyGoodsController
{
    int pagesize;
    int pagenum;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"创建搭配-我的单品页面"];
    [TalkingData trackPageBegin:@"创建搭配-我的单品页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"创建搭配-我的单品页面"];
    [TalkingData trackPageEnd:@"创建搭配-我的单品页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [NSMutableArray array];
    [self configSearchView];
    [self configCollectionView];
    __weak __typeof(&*self)weakSelf = self;
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getFirstPageData];
    }];
    [_collectionView.mj_header beginRefreshing];
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getNextPageData];
    }];
    _collectionView.mj_footer.automaticallyHidden = YES;
}
#pragma mark - UI
- (void)configSearchView {
    _searchView = [[SMAllGoodsSearchView alloc] init];
    _searchView.delegate = self;
    [self.view addSubview:_searchView];
    [_searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.right.top.equalTo(self.view);
    }];
}
- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat cellWidth = (self.view.bounds.size.width-1) / 3.0;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[SMMyGoodsCell class] forCellWithReuseIdentifier:@"SMMyGoodsCell"];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - network

/** http://ugcapp.ssrj.com/api/v1/goodsinfor/my_goods?appVersion=2.2.0&pagenum=1&pagesize=15&token=daf1a91acee1be236510cc2bd1873b49
 appVersion	2.2.0
 pagenum	1
 pagesize	15
 token	daf1a91acee1be236510cc2bd1873b49
 */

/**
 "data": [{
 "marketPrice": 124,
 "sn": "G64C718Q01-RD",
 "effectiveDiscount": 10.0,
 "videoPath": "",
 "largeImage": "http://www.ssrj.com/upload/image/201607/0fe671d6-3354-4823-aa51-71ea60b06265-large.png",
 "image": "http://www.ssrj.com/upload/image/201607/0fe671d6-3354-4823-aa51-71ea60b06265-medium.png",
 "mobilePath": null,
 "brandName": "Ginger+Soul",
 "discount": 8.4,
 "id": 1726,
 "effectivePrice": 104,
 "isgather": false,
 "isthumb": false,
 "price": 104,
 "thumbnail": "http://www.ssrj.com/upload/image/201607/0fe671d6-3354-4823-aa51-71ea60b06265-thumbnail.png",
 "source": "http://www.ssrj.com/upload/image/201607/0fe671d6-3354-4823-aa51-71ea60b06265-source.png",
 "maxImage": "http://www.ssrj.com/upload/image/201607/0fe671d6-3354-4823-aa51-71ea60b06265-max.png",
 "mediumImage": "http://www.ssrj.com/upload/image/201607/0fe671d6-3354-4823-aa51-71ea60b06265-medium.png",
 "name": "大红色细腰带",
 "imgsList": [{
 "imgThumbnail": "http://www.ssrj.com/upload/image/201607/56a869a0-1980-4503-afb2-41e40fe3ca73-large.jpg",
 "imgTitle": null
 }, {
 "imgThumbnail": "http://www.ssrj.com/upload/image/201607/70276c1d-0908-416a-9862-788d87344698-large.jpg",
 "imgTitle": null
 }],
 "default_img": "http://www.ssrj.com/resources/shop/mobile/images/default_goods.png",
 "isThumbsup": false,
 "isSpecialPrice": false,
 "isNewProduct": false
	},......
 */
- (void)getFirstPageData {
    pagesize = 15;
    pagenum = 1;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(pagesize) forKey:@"pagesize"];
    [params setObject:@(pagenum) forKey:@"pagenum"];
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = MyGoodsUrl;
    requestInfo.getParams = params;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            [weakSelf.dataArray removeAllObjects];
            pagenum++;
            for (NSDictionary *dict in responseObject[@"data"]) {
                NSError *error;
                RJBaseGoodModel *model = [[RJBaseGoodModel alloc] initWithDictionary:dict error:&error];
                if (!error) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [_collectionView reloadData];
            [_collectionView.mj_header endRefreshing];
            if (weakSelf.dataArray.count < pagesize) {
                [_collectionView.mj_footer setHidden:YES];
            }else {
                [_collectionView.mj_footer resetNoMoreData];
            }
        }else {
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];
            [_collectionView.mj_header endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
        [_collectionView.mj_header endRefreshing];
    }];
    
}
- (void)getNextPageData {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(pagesize) forKey:@"pagesize"];
    [params setObject:@(pagenum) forKey:@"pagenum"];
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = MyGoodsUrl;
    requestInfo.getParams = params;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            pagenum++;
            for (NSDictionary *dict in responseObject[@"data"]) {
                NSError *error;
                RJBaseGoodModel *model = [[RJBaseGoodModel alloc] initWithDictionary:dict error:&error];
                if (!error) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [_collectionView reloadData];
            if ([responseObject[@"data"] count] < pagesize) {
                [_collectionView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [_collectionView.mj_footer endRefreshing];
            }
        }else {
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];
            [_collectionView.mj_footer endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
        [_collectionView.mj_footer endRefreshing];
    }];
    
}

#pragma mark - delegate
#pragma mark -- searchBarDelegate

- (void)didClickCamara {
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    AJPhotoPickerViewController *picker = [[AJPhotoPickerViewController alloc] init];
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups = YES;
    //        picker.delegate=self;
    picker.minimumNumberOfSelection = 1;
    picker.maximumNumberOfSelection = 9;
    picker.multipleSelection = NO;
    picker.shouldClip = YES;
    picker.delegate = self;
    picker.cropMode = RSKImageCropModeSquare;
    
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return YES;
    }];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:picker];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)didClickSearchView {
    SMSearchGoodsController *vc = [SMSearchGoodsController new];
    vc.isFromAllGoods = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - photoDelegate

- (void)photoPickerDidClipImageDone:(UIImage *)image {
    [self uploadImageNet:image];
}
//上传图片
- (void)uploadImageNet:(UIImage *)image {
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:@"加载中" xOffset:0 yOffset:0];
    
    NSData *imagedata = UIImageJPEGRepresentation(image, 1);
    float qulity = 1;
    NSData *minData = [NSData dataWithData:imagedata];
    while (imagedata.length > 50 * 1024 && qulity >= 0.2) {
        qulity -= 0.1;
        imagedata = UIImageJPEGRepresentation(image, qulity);
        if (imagedata.length < minData.length) {
            minData = imagedata;
        }
    }
    if (imagedata.length > 50 * 1024) {
        imagedata = minData;
    }
    NSString *base64Str = [imagedata base64EncodedStringWithOptions:0];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"jpg" forKey:@"format"];
    [dict setObject:base64Str forKey:@"image"];
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = UploadImageUrl;
    requestInfo.postParams = dict;
    [[ZHNetworkManager sharedInstance] postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            if ([weakSelf.navigationController.parentViewController isKindOfClass:[SMCreateMatchController class]]) {
                SMCreateMatchController *createMatchVC = (SMCreateMatchController *)weakSelf.navigationController.parentViewController;
                
                SMGoodsModel *goodsModel = [[SMGoodsModel alloc] init];
                goodsModel.image = responseObject[@"data"][@"image"];
                [createMatchVC addGoodsOrSourceWithModel:goodsModel];
            }
        }else {
            [HTUIHelper addHUDToWindowWithString:responseObject[@"msg"] hideDelay:1];
        }
        [[HTUIHelper shareInstance] removeHUD];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToWindowWithString:@"error" hideDelay:1];
        [[HTUIHelper shareInstance] removeHUD];
    }];
}

#pragma mark - collectionDeledate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SMMyGoodsCell *cell = (SMMyGoodsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SMMyGoodsCell" forIndexPath:indexPath];
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    
    
    cell.model = model;
    if (indexPath.row % 3 != 0) {
        [cell hiddenLeftLine];
    }
    if (indexPath.row != 0 && indexPath.row != 1 && indexPath.row != 2) {
        [cell hiddenTopLine];
    }
    __weak __typeof(&*self)weakSelf = self;
    cell.clickAddBtnBlock = ^ {
        if ([weakSelf.navigationController.parentViewController isKindOfClass:[SMCreateMatchController class]]) {
            SMCreateMatchController *createMatchVC = (SMCreateMatchController *)weakSelf.navigationController.parentViewController;
            RJBaseGoodModel *model = weakSelf.dataArray[indexPath.row];
            SMGoodsModel *goodsModel = [[SMGoodsModel alloc] init];
            goodsModel.name = model.name;
            goodsModel.ID = model.goodId;
            goodsModel.image = model.source;
            [createMatchVC addGoodsOrSourceWithModel:goodsModel];
            [weakSelf.navigationController popToRootViewControllerAnimated:NO];
        }
        
    };
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    SMGoodsDetailController *detail = [[SMGoodsDetailController alloc]init];
    detail.goodsId = model.goodId;
    detail.model = model;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
