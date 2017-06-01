//
//  SMGoodsListViewController.m
//  ssrj
//
//  Created by 夏亚峰 on 17/1/6.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "SMGoodsListViewController.h"
#import "SMCreateMatchController.h"
#import "SMGoodsDetailController.h"

#import "GoodsListModel.h"

#import "SMMyGoodsCell.h"

#import "Masonry.h"


static NSString * const GoodsUrl = @"/api/v5/product/list.jhtml";

@interface SMGoodsListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) NSNumber *startNumber;
@property (nonatomic, assign) NSInteger pagesize;
@end

@implementation SMGoodsListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"创建搭配-所有单品详情页面"];
    [TalkingData trackPageBegin:@"创建搭配-所有单品详情页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建搭配-所有单品详情页面"];
    [TalkingData trackPageEnd:@"创建搭配-所有单品详情页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = [NSMutableArray array];
    _pagesize = 30;
    
    [self configCollectionView];
    
}
- (void)reloadData {
    [_collectionView.mj_header beginRefreshing];
}
#pragma mark - ui
- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat cellWidth = (self.view.bounds.size.width) / 3.0;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth * 1.3);
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
        make.edges.equalTo(self.view);
    }];
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getNetData];
    }];
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self getNextNetData];
    }];
    [self.collectionView.mj_header beginRefreshing];
    [_collectionView.mj_footer setAutomaticallyHidden:YES];
}
#pragma mark - collectionDeledate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SMMyGoodsCell *cell = (SMMyGoodsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SMMyGoodsCell" forIndexPath:indexPath];
    
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
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
        }
        
    };
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
/**
 <RJBaseGoodModel>
 [upTime]: <nil>
 [colorId]: <nil>
 [cloth]: <nil>
 [isthumb]: 0
 [isSpecialPrice]: 0
 [largeImage]: http://www.ssrj.com/upload/image/201611/68ee7ba2-d5c5-41f5-...
 [footageImage]: <nil>
 [downTime]: <nil>
 [effectivePrice]: 222
 [kaolaKey]: <nil>
 [unit]: <nil>
 [path]: <nil>
 [goodId]: 2371
 [caption]: <nil>
 [imgsList]: <2,3,0x170654c10>,[0x17042b7e0--1883420640] [0x17042b2e0--1883419360] [0x17042b3e0--1883419616]
 [image]: http://www.ssrj.com/upload/image/201611/68ee7ba2-d5c5-41f5-...
 [isgather]: 0
 [thumbnail]: http://www.ssrj.com/upload/image/201611/68ee7ba2-d5c5-41f5-...
 [mobilePath]: /mobile/goods/content/201611/2371.html
 [name]: 深蓝色牛仔连衣裙
 [isThumbsup]: 0
 [marketPrice]: 260
 [productCategoryId]: <nil>
 [price]: 222
 [isNewProduct]: 1
 [productCategoryName]: <nil>
 [brandName]: Parisian
 [brandId]: <nil>
 [default_img]: http://www.ssrj.com/resources/shop/mobile/images/default_go...
 [sn]: DRS5539
 [isNonSell]: <nil>
 [maxImage]: http://www.ssrj.com/upload/image/201611/68ee7ba2-d5c5-41f5-...
 [isMarketable]: <nil>
 [mediumImage]: http://www.ssrj.com/upload/image/201611/68ee7ba2-d5c5-41f5-...
 [weight]: <nil>
 [discount]: 8.6
 [memo]: <nil>
 [productRelationId]: <nil>
 [colorName]: <nil>
 </RJBaseGoodModel>
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    SMGoodsDetailController *detail = [[SMGoodsDetailController alloc]init];
    detail.goodsId = model.goodId;
    detail.model = model;
    [self.navigationController pushViewController:detail animated:YES];
    
}

- (void)getNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = GoodsUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":@"0",@"rows":@(_pagesize)}];
    if (self.ID.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"classifys": self.ID}];
    }
    //筛选！！！！
    if (self.filterDictionary) {
        NSMutableArray *category = [self.filterDictionary objectForKey:@"Category"];
        if (category.count) {
            NSString *str = [category componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"categoryTag":str}];
        }
        NSMutableArray *brand = [self.filterDictionary objectForKey:@"Brand"];
        if (brand.count) {
            NSString *str = [brand componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"brands":str}];
        }
        NSMutableArray *price = [self.filterDictionary objectForKey:@"Price"];
        if (price.count) {
            NSString *str = [price componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"prices":str}];
        }
        NSMutableArray *color = [self.filterDictionary objectForKey:@"Color"];
        if (color.count) {
            NSString *str = [color componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"colors":str}];
        }
        
    }
    
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [weakSelf.dataArray removeAllObjects];
        GoodsListModel *model = responseObject;
        if (model.state.boolValue == 0) {
            weakSelf.startNumber = model.start;
            [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
        }else{
            [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
        }
        
        [[HTUIHelper shareInstance]removeHUD];
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView.mj_header endRefreshing];
        
        if (weakSelf.dataArray.count < _pagesize) {
            [weakSelf.collectionView.mj_footer setHidden:YES];
        }else {
            [weakSelf.collectionView.mj_footer resetNoMoreData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUD];
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:@"error" hideDelay:2];
        
    }];
    
}
- (void)getNextNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = GoodsUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":self.startNumber,@"rows":@(_pagesize)}];
    
    if (self.ID.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"classifys": self.ID}];
    }
    //筛选！！！！
    if (self.filterDictionary) {
        NSMutableArray *category = [self.filterDictionary objectForKey:@"Category"];
        if (category.count) {
            NSString *str = [category componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"categoryTag":str}];
        }
        NSMutableArray *brand = [self.filterDictionary objectForKey:@"Brand"];
        if (brand.count) {
            NSString *str = [brand componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"brands":str}];
        }
        NSMutableArray *price = [self.filterDictionary objectForKey:@"Price"];
        if (price.count) {
            NSString *str = [price componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"prices":str}];
        }
        NSMutableArray *color = [self.filterDictionary objectForKey:@"Color"];
        if (color.count) {
            NSString *str = [color componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"colors":str}];
        }
        
    }
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GoodsListModel *model = responseObject;
        if (model.state.boolValue == 0) {
            weakSelf.startNumber = model.start;
            [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
            [weakSelf.collectionView reloadData];
            if (model.data.count < _pagesize) {
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }else {
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



@end
