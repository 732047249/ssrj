//
//  HHInforGoodsController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforGoodsController.h"
#import "HHInformationViewController.h"
#import "HHInforGoodsCell.h"
#import "HHInforSearchGoodsOrMatchView.h"
#import "SMSearchGoodsController.h"
#import "Masonry.h"
#import "UIImage+New.h"
#import "GoodsListModel.h"

@interface HHInforGoodsController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HHInforSearchGoodsOrMatchViewDelegate>


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) HHInforSearchGoodsOrMatchView *searchView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) GoodsListModel *model;
@property (strong, nonatomic) NSNumber * startNumber;
@end

@implementation HHInforGoodsController
{
    int pagenum;
    int pagesize;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"创建资讯-插入单品页面"];
    [TalkingData trackPageBegin:@"创建资讯-插入单品页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建资讯-插入单品页面"];
    [TalkingData trackPageEnd:@"创建资讯-插入单品页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    pagenum = 1;
    pagesize = 20;
    [self configSearchView];
    [self configCollectionView];
}
- (void)configSearchView {
    _searchView = [[HHInforSearchGoodsOrMatchView alloc] init];
    _searchView.delegate = self;
    _searchView.placeHolder = @"搜索您想要的单品";
    [self.view addSubview:_searchView];
    [_searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
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
        make.top.equalTo(_searchView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    __weak __typeof(&*self)weakSelf = self;
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [_collectionView.mj_header beginRefreshing];
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getNextNetData];
    }];
    [_collectionView.mj_footer setAutomaticallyHidden:YES];
}

/** https://api.ssrj.com/api/v4/product/list.jhtml?appVersion=2.2.0&rows=10&start=0&token=da83e19a50a084522343d96746f0d889
 
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
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/product/list.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":@"0",@"rows":[NSString stringWithFormat:@"%d",pagesize]}];
    
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            [[HTUIHelper shareInstance]removeHUD];
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                weakSelf.model = model;
                weakSelf.startNumber = model.start;
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                [weakSelf.collectionView reloadData];
                if (weakSelf.dataArray.count < pagesize) {
                    [weakSelf.collectionView.mj_footer setHidden:YES];
                }else {
                    [weakSelf.collectionView.mj_footer resetNoMoreData];
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
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
- (void)getNextNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = @"api/v5/product/list.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":self.startNumber,@"rows":@"10"}];
    requestInfo.modelClass = [GoodsListModel class];
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                weakSelf.startNumber = model.start;
                if (model.data.count) {
                    [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                    
                    [weakSelf.collectionView.mj_footer endRefreshing];
                    
                    [weakSelf.collectionView reloadData];
                }else{
                    //没数据了 关闭上拉加载更多
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                    return;
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
                [weakSelf.collectionView.mj_footer endRefreshing];
                
            }
            
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
            [weakSelf.collectionView.mj_footer endRefreshing];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:2];
        [weakSelf.collectionView.mj_footer endRefreshing];
        
    }];
}

#pragma mark - 点击searchView
- (void)didClickSearchView {
    SMSearchGoodsController *search = [[SMSearchGoodsController alloc] init];
    search.isFromInformation = YES;
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
            style.image = image;
            style.ID = [model.goodId intValue];
            [infor insertImageWithImageStyle:style];
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
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
