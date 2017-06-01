//
//  HHInforGoodsSearchDetailController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforGoodsSearchDetailController.h"
#import "HHInformationViewController.h"
#import "UIImage+New.h"
#import "HHInforGoodsCell.h"
#import "HHInforSearchGoodsOrMatchView.h"
#import "SMSearchGoodsController.h"
#import "Masonry.h"
#import "GoodsListModel.h"

@interface HHInforGoodsSearchDetailController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) HHInforSearchGoodsOrMatchView *searchView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) GoodsListModel *model;
@end

static NSString * const searchUrl = @"/b180/api/v1/goodsinfor/goods_search";

@implementation HHInforGoodsSearchDetailController
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.title = self.searchName;
    [self addBackButton];
    [self configCollectionView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [MobClick beginLogPageView:@"创建资讯-单品搜索详情页面"];
    [TalkingData trackPageBegin:@"创建资讯-单品搜索详情页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建资讯-单品搜索详情页面"];
    [TalkingData trackPageEnd:@"创建资讯-单品搜索详情页面"];
}
- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat cellWidth = (self.view.bounds.size.width) / 2.0;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth + 62);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[HHInforGoodsCell class] forCellWithReuseIdentifier:@"HHInforGoodsCell"];
    [self.view addSubview:_collectionView];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    __weak __typeof(&*self)weakSelf = self;
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [_collectionView.mj_header beginRefreshing];
}

/** http://192.168.1.173:9999/api/v1/goodsinfor/goods_search?name=裸色太阳眼镜&token=227a1368bd09faa8f94d9181710ba533&appVersion=22&pagenum=1&pagesize=10
 
 "data":[
 {
 "marketPrice":81,
 "sn":"RZ1600118-PK",
 "effectiveDiscount":10,
 "videoPath":"",
 "largeImage":"http://www.ssrj.com/upload/image/201612/a15768ca-8cf7-45ea-a6ba-0bb9c785dfe8-large.png",
 "image":"http://www.ssrj.com/upload/image/201612/a15768ca-8cf7-45ea-a6ba-0bb9c785dfe8-medium.png",
 "mobilePath":"/mobile/goods/content/201612/2484.html",
 "brandName":"MFD Labs",
 "discount":8.7,
 "id":2484,
 "effectivePrice":70,
 "isgather":false,
 "isthumb":false,
 "price":70,
 "thumbnail":"http://www.ssrj.com/upload/image/201612/a15768ca-8cf7-45ea-a6ba-0bb9c785dfe8-thumbnail.png",
 "source":"http://www.ssrj.com/upload/image/201612/a15768ca-8cf7-45ea-a6ba-0bb9c785dfe8-source.png",
 "maxImage":"http://www.ssrj.com/upload/image/201612/a15768ca-8cf7-45ea-a6ba-0bb9c785dfe8-max.png",
 "mediumImage":"http://www.ssrj.com/upload/image/201612/a15768ca-8cf7-45ea-a6ba-0bb9c785dfe8-medium.png",
 "name":"粉色仿皮草耳罩",
 "imgsList":[
 {
 "imgThumbnail":"http://www.ssrj.com/upload/image/201612/7a6e9310-d957-494a-915e-b56b9c7bf7ea-large.jpg",
 "imgTitle":null
 },
 {
 "imgThumbnail":"http://www.ssrj.com/upload/image/201612/fcd305f5-a877-4c52-98e0-49b64f1af315-large.jpg",
 "imgTitle":null
 }
 ],
 "default_img":"http://www.ssrj.com/resources/shop/mobile/images/default_goods.png",
 "isThumbsup":false,
 "isSpecialPrice":false,
 "isNewProduct":true
 },
 
 */

- (void)getNetData{
    if (!self.searchName.length) {
        [_collectionView.mj_header endRefreshing];
        return;
    }
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = searchUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                   @"name" : self.searchName}];
    
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            [[HTUIHelper shareInstance]removeHUD];
            [weakSelf.dataArray removeAllObjects];
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                weakSelf.model = model;
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
            [weakSelf.collectionView reloadData];
        }else{
            [[HTUIHelper shareInstance]removeHUD];
            
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        }
        [weakSelf.collectionView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUD];
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:2];
        
    }];
    
}
#pragma mark - 点击searchView
- (void)didClickSearchView {
    SMSearchGoodsController *search = [[SMSearchGoodsController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
}
#pragma mark - collectionDeledate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    
    HHInforGoodsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HHInforGoodsCell" forIndexPath:indexPath];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    
    cell.model = model;
    if (indexPath.row % 2 == 1) {
        [cell hiddenLeftLine];
    }
    if (indexPath.row != 0 && indexPath.row != 1) {
        [cell hiddenTopLine];
    }
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImage *image = [UIImage captureWithView:cell.contentView];
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[HHInformationViewController class]]) {
            HHInformationViewController *infor = (HHInformationViewController *)vc;
            HHImageStyle *style = [HHImageStyle imageStyleWithType:HHImageStyleTypeGoods];
            RJBaseGoodModel *model = self.dataArray[indexPath.row];
            style.ID = [model.goodId intValue];
            style.image = image;
            [infor insertImageWithImageStyle:style];
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
